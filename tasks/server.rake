require "highline/import"

namespace :server do

  desc "Bootstrap a Chef Server infrastructure"
  task :bootstrap do
    ENV['BOOTSTRAP'] = "1"

    # sanity check
    if Process.euid > 0
      $stderr.puts "You need to be root for server bootstrap"
      exit(1)
    end

    # collect data
    hostname = ask('Enter the hostname: ') do |q|
      q.default = 'chef'
      q.validate = /^\w+$/
    end

    domainname = ask('Enter the domain name: ') do |q|
      q.default = 'example.com'
      q.validate = /^[\w.]+$/
    end

    fqdn = "#{hostname}.#{domainname}"

    username = ask('Enter your username: ') do |q|
      q.validate = /^\w+$/
    end

    p1 = ask('Enter Password: ') do |q|
      q.echo = false
      q.validate = /^.{6}/
    end

    p2 = ask('Confirm: ') do |q|
      q.echo = false
    end

    raise "passwords do not match" unless p1 == p2

    salt = SecureRandom.hex(4)
    password = p1.crypt("$6$#{salt}$")

    # set FQDN
    %x(hostname #{hostname})

    File.open("/etc/hosts", 'w')  do |f|
      f.write("127.0.0.1 #{fqdn} #{hostname} localhost\n")
    end

    # create CA & SSL certificate for the server
    ENV['BATCH'] = "1"
    Rake::Task["ssl:do_cert"].invoke(fqdn)

    # bootstrap the chef server
    scfg = File.join(TOPDIR, "bootstrap", "server", "solo.rb")
    sjson = File.join(TOPDIR, "bootstrap", "server", "solo.json")

    sh("chef-solo -c #{scfg} -j #{sjson} -N #{fqdn}")

    # run chef-client to register a client key
    sh("chef-client")

    # setup a client key for root
    sh("knife client create root -a -n -u chef-webui -k /etc/chef/webui.pem | tail -n+2 > /root/.chef/client.pem")

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
    Rake::Task['load:all'].invoke

    # run final chef-client
    3.times do
      sh("chef-client")
    end
  end

end
