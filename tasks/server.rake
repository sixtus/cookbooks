namespace :server do

  desc "Bootstrap a Chef Server infrastructure"
  task :bootstrap, :fqdn, :username do |t, args|
    ENV['BOOTSTRAP'] = "1"
    ENV['BATCH'] = "1"
    ENV['SOLO'] = "1"

    # sanity check
    if Process.euid > 0
      $stderr.puts "You need to be root for server bootstrap"
      exit(1)
    end

    login = args.username

    fqdn = args.fqdn
    hostname = fqdn.split('.').first
    domainname = fqdn.sub(/^#{hostname}\./, '')

    # set FQDN
    %x(hostnamectl set-hostname #{hostname})

    File.open("/etc/hosts", 'w')  do |f|
      f.write("127.0.0.1 #{fqdn} #{hostname} localhost\n")
    end

    # create CA & SSL certificate for the server
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

    # setup a client key for root
    sh("env EDITOR=vim knife client create root -a -d -u chef-webui -k /etc/chef/webui.pem | tail -n+2 > /root/.chef/client.pem")

    # setup a client key for the first user
    sh("env EDITOR=vim knife client create #{login} -a -d -u chef-webui -k /etc/chef/webui.pem | tail -n+2 > #{TOPDIR}/.chef/client.pem")

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

    name = login
    email = "hostmaster@#{domainname}"
    tags = "hostmaster"
    keys = []

    random = "tux"
    salt = SecureRandom.hex(8)
    password1 = random.crypt("$1$#{salt}$")
    salt = SecureRandom.hex(4)
    password = random.crypt("$6$#{salt}$")

    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'user_databag.rb')))

    path = File.join(BAGS_DIR, "users")
    FileUtils.mkdir_p(path)

    File.open(File.join(path, "#{login}.rb"), "w") do |f|
      f.puts(erb.result(b))
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
