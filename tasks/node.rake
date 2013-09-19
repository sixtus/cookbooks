require 'resolv'

namespace :node do

  task :checkdns, :fqdn, :ipaddress do |t, args|
    ip = Resolv.getaddress(args.fqdn)
    if ip != args.ipaddress
      raise "IP #{args.ipaddress} does not match resolved address #{ip} for FQDN #{args.fqdn}"
    end
  end

  desc "Create a new node with SSL certificates"
  task :create => [ :pull ]
  task :create, :fqdn, :ipaddress do |t, args|
    fqdn, ipaddress = args.fqdn, args.ipaddress
    Rake::Task['node:checkdns'].invoke(fqdn, ipaddress)

    # create SSL cert
    ENV['BATCH'] = "1"
    Rake::Task['ssl:do_cert'].invoke(fqdn)
    knife :cookbook_upload, ['openssl', '--force']

    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'node.rb')))

    # create new node
    nf = File.join(TOPDIR, "nodes", "#{fqdn}.rb")

    unless File.exists?(nf)
      File.open(nf, "w") do |f|
        f.puts(erb.result(b))
      end
    end

    # upload to chef server
    Rake::Task['load:node'].invoke(fqdn)
  end

  desc "Bootstrap the specified node"
  task :bootstrap, :fqdn, :ipaddress do |t, args|
    ENV['DISTRO'] ||= "gentoo"
    Rake::Task['node:create'].invoke(args.fqdn, args.ipaddress)
    sh("knife bootstrap #{args.fqdn} --distro #{ENV['DISTRO']} -P tux")
    env = "/usr/bin/env UPDATEWORLD_DONT_ASK=1"
    system("ssh -t #{args.fqdn} '/usr/bin/sudo -i #{env} /usr/local/sbin/updateworld'")
    reboot_wait(node.name)
  end

  desc "Quickstart & Bootstrap the specified node"
  task :quickstart, :fqdn, :ipaddress, :profile do |t, args|
    args.with_defaults(:profile => 'generic-two-disk-md')

    # create DNS/rDNS records
    name = args.fqdn.sub(/\.#{chef_domain}$/, '')
    hetzner_server_name_rdns(args.ipaddress, name, args.fqdn)
    zendns_add_record(args.fqdn, args.ipaddress)
    Rake::Task['node:checkdns'].invoke(args.fqdn, args.ipaddress)

    # quick start
    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'quickstart.sh')))

    tmpfile = Tempfile.new('quickstart')
    tmpfile.write(erb.result(b))
    tmpfile.rewind

    sh(%{cat #{tmpfile.path} | ssh -l root -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "GlobalKnownHostsFile /dev/null" #{args.ipaddress} "bash -s"})

    tmpfile.unlink

    # wait until machine is up again
    wait_with_ping(args.ipaddress, false)
    wait_with_ping(args.ipaddress, true)

    # run normal bootstrap
    Rake::Task['node:bootstrap'].invoke(args.fqdn, args.ipaddress)
  end

  desc "Delete the specified node, client key and SSL certificates"
  task :delete, :fqdn do |t, args|
    fqdn = args.fqdn

    # revoke SSL cert
    ENV['BATCH'] = "1"

    begin
      Rake::Task['ssl:revoke'].invoke(fqdn)
    rescue
      # do nothing
    end

    # remove node
    begin
      File.unlink(File.join(TOPDIR, "nodes", "#{fqdn}.rb"))
    rescue
      # do nothing
    end

    knife :node_delete, [fqdn, '-y']
    knife :client_delete, [fqdn, '-y']
  end

end
