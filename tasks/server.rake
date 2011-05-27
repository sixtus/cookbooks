namespace :server do

  desc "Bootstrap a Chef Server infrastructure"
  task :bootstrap do
    fqdn = %x(hostname -f).chomp

    # create CA & SSL certificate for the server
    ENV['BATCH'] = "1"
    Rake::Task["ssl:do_cert"].invoke(fqdn)

    # bootstrap the chef server
    scfg = File.join(TOPDIR, "bootstrap", "solo.rb")
    sjson = File.join(TOPDIR, "bootstrap", "bootstrap.json")

    sh("chef-solo -L /dev/stdout -c #{scfg} -j #{sjson}")

    # run chef-client to register a client key
    sh("chef-client -V")

    # setup a client key for root
    sh("knife client create root -a -n -u chef-webui -k /etc/chef/webui.pem | tail -n+2 > /root/.chef/client.pem")

    # create new node
    nf = File.join(NODES_DIR, "#{fqdn}.rb")

    File.open(nf, "w") do |fd|
      fd.puts "run_list(%w(\n  role[chef]\n))"
    end

    # create initial user account
    print "Please enter your username: "
    username = STDIN.gets.chomp

    uf = File.join(BAGS_DIR, "users", "#{username}.rb")

    File.open(uf, "w") do |fd|
      fd.puts "self[:tags] = %w(hostmaster)"
    end

    begin
      File.unlink(File.join(BAGS_DIR, "users", "john.rb"))
    rescue
    end

    # deploy initial repository
    Rake::Task['deploy'].invoke

    # run final chef-client
    sh("chef-client -V")
  end

end
