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

    inwx_add_record(args.fqdn, ipaddress)
    hetzner_server_name_rdns(ipaddress, args.fqdn)
    ovh_server_name_rdns(args.ipaddress, args.fqdn)
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
    args.with_defaults(:profile => 'generic-two-disk-md')
    raise "missing parameters!" unless args.fqdn && args.ipaddress

    # create DNS/rDNS records
    run_task('node:checkdns', args.fqdn, args.ipaddress)

    # quick start
    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'quickstart.sh')))
    tmpfile = Tempfile.new('quickstart')
    tmpfile.write(erb.result(b))
    tmpfile.rewind
    sshlive(args.ipaddress, ENV['PASSWORD'], tmpfile.path)
    tmpfile.unlink

    # wait until machine is up again
    wait_with_ping(args.ipaddress, false)
    wait_with_ping(args.ipaddress, true)

    # run normal bootstrap
    ENV['REBOOT'] = "1"
    run_task('node:bootstrap', args.fqdn, args.ipaddress)
  end

  desc "Bootstrap the specified node"
  task :bootstrap, :fqdn, :ipaddress, :password do |t, args|
    args.with_defaults(password: "tux")
    ENV['BATCH'] = "1"
    ENV['CREATE'] ||= "1"
    ENV['DISTRO'] ||= "gentoo"
    ENV['ROLE'] ||= "bootstrap"
    ENV['ENVIRONMENT'] ||= "production"
    run_task('node:checkdns', args.fqdn, args.ipaddress)
    run_task('ssl:do_cert', args.fqdn)
    knife :upload, ["cookbooks/certificates"]
    key = File.join(ROOT, "tasks/support/id_rsa")
    sh("knife bootstrap #{args.fqdn} --no-host-key-verify --no-node-verify-api-cert --node-ssl-verify-mode none -t #{ENV['DISTRO']} -P #{args.password} -r 'role[#{ENV['ROLE']}]' -E #{ENV['ENVIRONMENT']} -i #{key}")
  end

  desc "Update node packages"
  task :updateworld, :fqdn do |t, args|
    system("ssh -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' -o 'GlobalKnownHostsFile /dev/null' -t #{args.fqdn} '/usr/bin/sudo -i eix-sync -q'")
    env = "/usr/bin/env UPDATEWORLD_DONT_ASK=1" if ENV['BATCH']
    system("ssh -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' -o 'GlobalKnownHostsFile /dev/null' -t #{args.fqdn} '/usr/bin/sudo -i #{env} /usr/local/sbin/updateworld'")
    reboot_wait(args.fqdn) if ENV['REBOOT']
    system("ssh -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' -o 'GlobalKnownHostsFile /dev/null' -t #{args.fqdn} '/usr/bin/sudo -i ntpdate pool.ntp.org'")
    system("ssh -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' -o 'GlobalKnownHostsFile /dev/null' -t #{args.fqdn} '/usr/bin/sudo -i #{env} chef-client'")
  end

  # private

  task :checkdns, :fqdn, :ipaddress do |t, args|
    inwx_add_record(args.fqdn, args.ipaddress)
    hetzner_server_name_rdns(args.ipaddress, args.fqdn)
    ovh_server_name_rdns(args.ipaddress, args.fqdn)

    ip = Resolv.getaddress(args.fqdn)
    if ip != args.ipaddress
      raise "IP #{args.ipaddress} does not match resolved address #{ip} for FQDN #{args.fqdn}"
    end
  end

end
