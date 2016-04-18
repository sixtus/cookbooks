require 'resolv'

task :pull do
  unless ENV.include?('BOOTSTRAP')
    sh("git checkout -q master")
    sh("git pull -q")
  end
end

namespace :node do

  desc "Create node with environment and run_list"
  task :create, :fqdn, :env, :run_list do |t, args|
    args.with_defaults(env: 'production', run_list: 'role[base]')
    stdout, stderr, status = knife_capture :node_show, [args.fqdn, '-F', 'json']
    raise "node already exists" if status == 0
    stdout, stderr, status = knife :node_create, [args.fqdn, '-d']
    if status != 0
      STDOUT.write(stdout)
      STDERR.write(stderr)
      raise "failed to get node data"
    end
    knife :node_environment_set, [args.fqdn, args.env]
    knife :node_run_list_set, [args.fqdn] + args.run_list.split(' ')
  end

  desc "Copy environment and run_list from other node"
  task :copy, :other, :fqdn do |t, args|
    stdout, stderr, status = knife_capture :node_show, [args.other, '-F', 'json']
    if status != 0
      STDOUT.write(stdout)
      STDERR.write(stderr)
      raise "failed to get node data"
    end
    node = JSON.load(stdout)
    run_task('node:create', args.fqdn, node['chef_environment'], node['run_list'].join(' '))
  end

  desc "Delete node, rename host and bootstrap again"
  task :rename, :old, :fqdn do |t, args|
    ipaddress = Resolv.getaddress(args.old)

    hetzner_server_name_rdns(ipaddress, args.fqdn)
    zendns_add_record(args.fqdn, ipaddress)
    run_task('node:checkdns', args.fqdn, ipaddress)

    sh("ssh #{args.old} sudo rm -f /etc/chef/client.pem")
    sh("ssh #{args.old} sudo sed -i -e 's/#{args.old}/#{args.fqdn}/g' /etc/chef/client.rb")
    sh("ssh #{args.old} sudo sed -i -e 's/#{args.old}/#{args.fqdn}/g' /etc/hosts")

    old_hostname = args.old.split('.').first
    hostname = args.fqdn.split('.').first
    sh("ssh #{args.old} sudo sed -i -e 's/#{old_hostname}/#{hostname}/g' /etc/hosts")
    sh("ssh #{args.old} sudo hostname #{hostname}")

    run_task('node:copy', args.old, args.fqdn)

    tmpfile = Tempfile.new('chef_client_key')
    stdout, stderr, status = knife_capture :client_create, [args.fqdn, '-d', '-f', tmpfile.path]
    if status != 0
      STDOUT.write(stdout)
      STDERR.write(stderr)
      raise "failed to create new client key for node"
    end

    sh("cat #{tmpfile.path} | ssh #{args.old} 'sudo tee /etc/chef/client.pem'")
    tmpfile.unlink

    ENV['BATCH'] = "1"
    run_task('ssl:do_cert', args.fqdn)
    knife :upload, ["cookbooks/certificates"]

    sh("ssh #{args.old} sudo chef-client")

    run_task('node:delete', args.old)
  end

  desc "Delete the specified node, client key and SSL certificates"
  task :delete, :fqdn do |t, args|
    fqdn = args.fqdn
    ENV['BATCH'] = "1"
    run_task('ssl:revoke', fqdn) rescue nil
    File.unlink(File.join(ROOT, "nodes", "#{fqdn}.json")) rescue nil
    knife :delete, ['-y', "nodes/#{fqdn}.json", "clients/#{fqdn}.json"] rescue nil
  end

  desc "quickstart & bootstrap machine"
  task :quickstart, :fqdn, :ipaddress, :profile do |t, args|
    raise "missing parameters!" unless args.fqdn && args.ipaddress && args.profile

    # load profile
    profile = File.read(File.join(ROOT, "config/quickstart", "#{args.profile}.sh"))
    ssh_authorized_key = File.read(File.join(ROOT, "tasks/support/id_rsa.pub")).chomp

    # create DNS/rDNS records
    run_task('node:checkdns', args.fqdn, args.ipaddress)

    # quick start
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'quickstart.sh')))
    tmpfile = Tempfile.new('quickstart')
    tmpfile.write(erb.result(
      profile: profile,
      ssh_authorized_key: ssh_authorized_key,
    ))

    tmpfile.rewind
    sshlive(args.ipaddress, ENV['PASSWORD'], tmpfile.path)
    tmpfile.unlink

    # reboot & wait until machine is up again
    sshlive(args.fqdn, ENV['PASSWORD'], "reboot")
    wait_for_ssh(args.fqdn, false)

    # run normal bootstrap
    run_task('node:bootstrap', args.fqdn, args.ipaddress)
  end

  desc "Bootstrap the specified node"
  task :bootstrap, :fqdn, :ipaddress do |t, args|
    ENV['BATCH'] = "1"
    ENV['DISTRO'] ||= "gentoo"
    ENV['ROLE'] ||= "bootstrap"
    ENV['ENVIRONMENT'] ||= "production"

    run_task('node:checkdns', args.fqdn, args.ipaddress)
    run_task('ssl:do_cert', args.fqdn)
    knife :upload, ["cookbooks/certificates"]

    sh("knife node create -d #{args.fqdn}")
    sh("knife node environment set #{args.fqdn} #{ENV['ENVIRONMENT']}")
    sh("knife node run list set #{args.fqdn} 'role[#{ENV['ROLE']}]'")
    sh("knife bootstrap #{args.fqdn} " +
       "--no-host-key-verify " +
       "--no-node-verify-api-cert " +
       "--node-ssl-verify-mode none " +
       "-t #{ENV['DISTRO']} " +
       "-r 'role[#{ENV['ROLE']}]' " +
       "-E #{ENV['ENVIRONMENT']} " +
       "-i tasks/support/id_rsa")

    ENV['REBOOT'] = "1"
    run_task('node:updateworld', args.fqdn)
  end

  desc "Update node packages"
  task :updateworld, :fqdn do |t, args|
    if ENV['BATCH']
      ssh_opts = "-o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' -o 'GlobalKnownHostsFile /dev/null'"
    else
      ssh_opts = ""
    end
    system("ssh -t #{args.fqdn} #{ssh_opts} '/usr/bin/sudo -i eix-sync -q'")
    env = "/usr/bin/env UPDATEWORLD_DONT_ASK=1" if ENV['BATCH']
    system("ssh -t #{args.fqdn} #{ssh_opts} '/usr/bin/sudo -i #{env} /usr/local/sbin/updateworld'")
    if ENV['REBOOT']
      system("ssh -t #{args.fqdn} #{ssh_opts} '/usr/bin/sudo -i reboot'")
      wait_for_ssh(args.fqdn)
      system("ssh -t #{args.fqdn} #{ssh_opts} '/usr/bin/sudo -i #{env} chef-client'")
    end
  end

  desc "Convert node to networkd with private interface"
  task :networkd, :fqdn, :public, :private do |t, args|
    sh("cat scripts/convert-to-networkd.sh | ssh #{args.fqdn} 'sudo bash -x -s #{args.public} #{args.private}'")
  end

  # private

  task :checkdns, :fqdn, :ipaddress do |t, args|
    hetzner_server_name_rdns(args.ipaddress, args.fqdn)
    ovh_server_name_rdns(args.ipaddress, args.fqdn)
    zendns_add_record(args.fqdn, args.ipaddress)

    ip = Resolv.getaddress(args.fqdn)
    if ip != args.ipaddress
      raise "IP #{args.ipaddress} does not match resolved address #{ip} for FQDN #{args.fqdn}"
    end
  end

end
