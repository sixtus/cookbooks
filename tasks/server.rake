namespace :server do

  desc "Bootstrap a Chef Server infrastructure"
  task :bootstrap, :fqdn, :username do |t, args|
    ENV['BOOTSTRAP'] = "1"

    # sanity check
    if Process.euid > 0
      $stderr.puts "You need to be root for server bootstrap"
      exit(1)
    end

    fqdn = args.fqdn
    hostname = fqdn.split('.').first
    domainname = fqdn.sub(/^#{hostname}\./, '')

    username = args.username

    salt = SecureRandom.hex(4)
    password = "tux".crypt("$6$#{salt}$")

    # set FQDN
    %x(hostname #{hostname})

    File.open("/etc/hosts", 'w')  do |f|
      f.write("127.0.0.1 #{fqdn} #{hostname} localhost\n")
    end

    # create CA & SSL certificate for the server
    ENV['BATCH'] = "1"
    Rake::Task["ssl:do_cert"].invoke(fqdn)

    # bootstrap the chef server
    scfg = File.join(TOPDIR, "config", "solo.rb")
    sjson = File.join(TOPDIR, "config", "solo", "server.json")

    sh("chef-solo -c #{scfg} -j #{sjson} -N #{fqdn} || :")

    # now this one is really ugly. no idea why the init script is so damn
    # broken that it is always stuck in starting state on the first run ...
    sh("kill $(</var/run/chef/expander.pid)")
    sh("/etc/init.d/chef-expander restart")
    sh("false; while [[ $? -ne 0 ]]; do chef-solo -c #{scfg} -j #{sjson} -N #{fqdn}; done")

    # run chef-client to register a client key
    sh("chef-client")

    # setup a client key for root
    sh("env EDITOR=vim knife client create root -a -d -u chef-webui -k /etc/chef/webui.pem | tail -n+2 > /root/.chef/client.pem")

    # create new node
    nf = File.join(NODES_DIR, "#{fqdn}.rb")

    File.open(nf, "w") do |fd|
      fd.puts "run_list(%w(\n  role[chef]\n))"
    end

    # create initial user account
    begin
      File.unlink(File.join(BAGS_DIR, "users", "john.rb"))
    rescue
    end

    uf = File.join(BAGS_DIR, "users", "#{username}.rb")

    File.open(uf, "w") do |fd|
      fd.puts "tags %w(hostmaster)"
      fd.puts "password '#{password}'"
    end

    # deploy initial repository
    begin
      Rake::Task['load:all'].invoke
    rescue
      Rake::Task['load:all'].invoke
    end

    # run final chef-client
    3.times do
      sh("chef-client")
    end
  end

end
