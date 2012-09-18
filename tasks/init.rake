require "highline/import"
require "net/ssh"

desc "Initialize the Chef repository"
task :init do
  # collect data
  node_name = ask('Your chef server API username: ') do |q|
    q.default = %x(whoami).chomp
    q.validate = /^\w+$/
  end

  chef_server_url = ask('Hostname of your chef server: ') do |q|
    q.default = %x(hostname -f).chomp
    q.validate = /^[\w.]+$/
  end

  b = binding()
  erb = Erubis::Eruby.new(File.read(KNIFE_CONFIG_FILE + ".erb"))

  File.open(KNIFE_CONFIG_FILE, "w") do |f|
    f.puts(erb.result(b))
  end

  unless File.exist?(CLIENT_KEY_FILE)
    File.open(CLIENT_KEY_FILE, "w") do |f|
      Net::SSH.start(chef_server_url, node_name) do |ssh|
        cmd = "sudo knife client create #{node_name} -a -d -u root -k /root/.chef/client.pem | tail -n+2"
        f.write(ssh.exec!(cmd))
      end
    end
  end
end
