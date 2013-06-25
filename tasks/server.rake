namespace :server do

  desc "Bootstrap a Chef Server infrastructure"
  task :bootstrap, :fqdn, :username, :key do |t, args|
    ENV['BOOTSTRAP'] = "1"
    ENV['BATCH'] = "1"
    ENV['ROLE'] = "chef"

    # sanity check
    if Process.euid > 0
      $stderr.puts "You need to be root for server bootstrap"
      exit(1)
    end

    login = args.username
    key = args.key || ""

    fqdn = args.fqdn
    hostname = fqdn.split('.').first
    domainname = fqdn.split('.')[1..-1].join('.')
    ipaddress = "10.42.9.2"

    # set FQDN
    %x(hostnamectl set-hostname #{hostname})

    File.open("/etc/hosts", 'w')  do |f|
      f.write("127.0.0.1 #{fqdn} #{hostname} localhost\n")
    end

    # create CA & SSL certificate for the server
    Rake::Task["ssl:init"].execute
    args = Rake::TaskArguments.new([:cn], ["*.#{domainname}"])
    Rake::Task["ssl:do_cert"].execute(args)
    args = Rake::TaskArguments.new([:cn], [fqdn])
    Rake::Task["ssl:do_cert"].execute(args)

    # bootstrap the chef server
    scfg = File.join(TOPDIR, "config", "solo.rb")
    sjson = File.join(TOPDIR, "config", "solo", "server.json")

    sh("chef-solo -c #{scfg} -j #{sjson} -N #{fqdn} || :")

    # run chef-client to register a client key
    sh("chef-client")

    # setup a client key for root and initial user
    knife :client_create, %W(root -a -d -u chef-webui -k /etc/chef/webui.pem -f /root/.chef/client.pem)
    knife :client_create, %W(#{login} -a -d -u chef-webui -k /etc/chef/webui.pem -f #{TOPDIR}/.chef/client.pem)

    # create new node
    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'node.rb')))

    # create new node
    nf = File.join(TOPDIR, "nodes", "#{fqdn}.rb")

    unless File.exists?(nf)
      File.open(nf, "w") do |f|
        f.puts(erb.result(b))
      end
    end

    # create initial user account
    begin
      File.unlink(File.join(BAGS_DIR, "users", "john.rb"))
    rescue
    end

    args = Rake::TaskArguments.new([
      :login,
      :name,
      :email,
      :tags,
      :key,
    ], [
      login,
      login,
      "hostmaster@#{domainname}",
      "hostmaster",
      key,
    ])

    Rake::Task["user:create"].execute(args)

    # deploy initial repository
    node_name = login
    chef_server_url = fqdn

    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'knife.rb')))

    File.open(File.expand_path(File.join(TOPDIR, ".chef", "knife.rb")), "w") do |f|
      f.puts(erb.result(b))
    end

    knife :cookbook_upload, ["--all", "--force"]
    Rake::Task['load:all'].invoke

    # run final chef-client
    3.times do
      sh("chef-client")
    end
  end

end
