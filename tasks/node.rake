require 'socket'

namespace :node do

  task :checkdns, :fqdn, :ipaddress do |t, args|
    ip = Addrinfo.getaddrinfo(args.fqdn, nil)[0].ip_address
    if ip != args.ipaddress
      raise "IP #{args.ipaddress} does not match resolved address #{ip} for FQDN #{args.fqdn}"
    end
  end

  desc "Create a new node with SSL certificates and chef client key"
  task :create => [ :pull ]
  task :create, :fqdn, :ipaddress, :role do |t, args|
    Rake::Task['node:checkdns'].invoke(args.fqdn, args.ipaddress)
    args.with_defaults(:role => "base")

    # create SSL cert
    ENV['BATCH'] = "1"
    Rake::Task['ssl:do_cert'].invoke(args.fqdn)
    Rake::Task['load:cookbook'].invoke('openssl')

    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'node.rb')))

    # create new node
    nf = File.join(TOPDIR, "nodes", "#{args.fqdn}.rb")

    unless File.exists?(nf)
      File.open(nf, "w") do |f|
        f.puts(erb.result(b))
      end
    end

    # upload to chef server
    Rake::Task['load:node'].invoke(args.fqdn)
  end

  desc "Bootstrap the specified node"
  task :bootstrap, :fqdn, :ipaddress, :role do |t, args|
    Rake::Task['node:create'].invoke(args.fqdn, args.ipaddress, args.role)
    knife :bootstrap, [args.fqdn, "--distro", "gentoo", "-P", "tux"]
  end

  desc "Quickstart & Bootstrap the specified node"
  task :quickstart, :fqdn, :ipaddress, :profile, :role do |t, args|
    args.with_defaults(:profile => 'generic-two-disk-md')

    # sanity check
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
    Rake::Task['node:bootstrap'].invoke(args.fqdn, args.ipaddress, args.role)
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

    Rake::Task['load:cookbook'].invoke('openssl')

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
