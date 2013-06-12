require "highline/import"
require "net/ssh"

desc "Initialize the Chef repository"
task :init do
  unless File.exist?(CLIENT_KEY_FILE)
    STDERR.puts "private key is missing (#{CLIENT_KEY_FILE})"
    STDERR.puts "please contact your hostmaster for assistance"
    exit 1
  end

  # collect data
  node_name = ask('Your chef server API username: ') do |q|
    q.default = Chef::Config[:node_name] || %x(whoami).chomp
    q.validate = /^\w+$/
  end

  chef_server_url = ask('Hostname of your chef server: ') do |q|
    q.default = URI.parse(Chef::Config[:chef_server_url]).host
    q.validate = /^[\w.]+$/
  end

  b = binding()
  erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'knife.rb')))

  File.open(KNIFE_CONFIG_FILE, "w") do |f|
    f.puts(erb.result(b))
  end
end
