require "highline/import"

namespace :generate do

  desc "Generate a cookbook skeleton"
  task :cookbook do
    name = ask('Cookbook name: ') do |q|
      q.validate = /^\w+$/
    end

    description = ask('Cookbook description: ')
    platforms = ask('Cookbook platforms: ').split(/\s/)
    platforms = %w(gentoo) if platforms.empty?

    maintainer = %x(git config user.name).chomp
    maintainer_email = %x(git config user.email).chomp

    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'metadata.rb')))

    cb_path = File.join(COOKBOOKS_DIR, name)
    FileUtils.mkdir_p(cb_path)

    File.open(File.join(cb_path, "metadata.rb"), "w") do |f|
      f.puts(erb.result(b))
    end

    FileUtils.mkdir_p(File.join(cb_path, "recipes"))

    %w(files templates).each do |d|
      FileUtils.mkdir_p(File.join(cb_path, d, "default"))
    end

    File.open(File.join(cb_path, "recipes", "default.rb"), "w") do |f|
      f.write "# add some resources here\n"
    end
  end

  task :metadata do
    generate_metadata
  end

  desc "Generate the production environment"
  task :env => :metadata do
    env = File.open(File.join(ENVIRONMENTS_DIR, "production.rb"), "w")
    env.printf %{description "The production environment"\n\n}

    cookbook_metadata.each do |cookbook, metadata|
      platforms = metadata[:platforms].keys - CHEF_SOLO_PLATFORMS
      version = metadata[:version]

      next if platforms.empty?

      env.printf %{cookbook %-20s "= %s"\n}, %{"#{cookbook}",}, version
    end

    env.close
  end

  desc "Generate a new user data bag"
  task :user do
    login = ask('Login: ') do |q|
      q.validate = /^\w+$/
    end

    name = ask('Name: ')
    email = ask('E-Mail: ')
    tags = ask('Tags (space-seperated): ')
    key = ask('SSH Public Key: ')

    args = Rake::TaskArguments.new([:cn], [login])
    Rake::Task["ssl:do_cert"].execute(args)

    random = %x(pwgen -s 10 1).chomp

    puts
    puts ">>> Creating new user #{login} with password #{random} <<<"
    puts

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
  end

  desc "Generate a default OpenVPN/Tunnelblick config"
  task :tunnelblick do
    remote = "chef." + URI.parse(Chef::Config[:chef_server_url]).host.split('.')[1..-1].join('.')
    login = Chef::Config[:node_name]

    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'openvpn.conf')))

    tmpdir = Dir.mktmpdir
    path = File.join(tmpdir, "#{COMPANY_NAME} VPN.tblk")
    FileUtils.mkdir_p(path)

    File.open(File.join(path, "config.ovpn"), "w") do |f|
      f.puts(erb.result(b))
    end

    FileUtils.cp(File.join(SSL_CERT_DIR, "ca.crt"),
                 File.join(path, "ca.crt"))
    FileUtils.cp(File.join(SSL_CERT_DIR, "#{login}.crt"),
                 File.join(path, "#{login}.crt"))
    FileUtils.cp(File.join(SSL_CERT_DIR, "#{login}.key"),
                 File.join(path, "#{login}.key"))

    puts ">>> Configuration is at #{path}"
    system("open '#{path}' || :")
  end

end
