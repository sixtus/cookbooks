require 'socket'

def check_ping(ipaddress)
  reachable = nil

  begin
    sh("ping -c 1 -w 5 #{ipaddress} &>/dev/null")
    reachable = true
    sleep(1)
  rescue
    reachable = false
  end

  return reachable
end

def wait_with_ping(ipaddress, reachable)
  print "Waiting for machine to #{reachable ? "boot" : "shutdown"} "

  while check_ping(ipaddress) != reachable
    print "."
  end

  print "\n"
end

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

    # create new node
    nf = File.join(TOPDIR, "nodes", "#{args.fqdn}.rb")

    unless File.exists?(nf)
      File.open(nf, "w") do |fd|
        fd.puts <<EOF
set[:primary_ipaddress] = "#{args.ipaddress}"

run_list(%w(
  role[#{args.role}]
))
EOF
      end
    end

    # upload to chef server
    Rake::Task['load:node'].invoke(args.fqdn)
  end

  desc "Bootstrap the specified node"
  task :bootstrap, :fqdn, :ipaddress, :role do |t, args|
    Rake::Task['node:create'].invoke(args.fqdn, args.ipaddress, args.role)
    sh("knife bootstrap #{args.fqdn} --distro gentoo -P tux")
  end

  desc "Quickstart & Bootstrap the specified node"
  task :quickstart, :fqdn, :ipaddress, :profile, :role do |t, args|
    args.with_defaults(:profile => 'generic-two-disk-md')

    # sanity check
    Rake::Task['node:checkdns'].invoke(args.fqdn, args.ipaddress)

    # quick start
    tmpfile = Tempfile.new('quickstart')
    tmpfile.write <<-EOF
#!/bin/bash
cd /tmp
wget -q -O quickstart.tar.gz https://github.com/zentoo/quickstart/tarball/master
tar -xzf quickstart.tar.gz
cd *-quickstart-*
exec ./quickstart profiles/#{args.profile}.sh
    EOF

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

    sh("knife node delete -y #{fqdn}")
    sh("knife client delete -y #{fqdn}")
  end

end
