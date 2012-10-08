namespace :node do

  desc "Create a new node with SSL certificates and chef client key"
  task :create => [ :pull ]
  task :create, :fqdn, :ipaddress, :role do |t, args|
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
    args.with_defaults(:profile => '2tb-two-disk-md')

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
    puts tmpfile.read

    sh(%{cat #{tmpfile.path} | ssh -t -l root -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "GlobalKnownHostsFile /dev/null" #{args.ipaddress} "bash -x -s"})

    tmpfile.unlink

    # wait until machine is up again
    print "Waiting for machine to boot "
    booted = false
    while !booted
      begin
        sh("ping -c 1 -w 5 #{args.ipaddress} &>/dev/null")
        booted = true
        print "\n"
      rescue
        print "."
      end
    end

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
