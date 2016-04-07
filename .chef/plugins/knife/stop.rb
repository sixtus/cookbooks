require 'chef/knife'

module KnifeStop
  class Stop < Chef::Knife

    deps do
      require 'chef/search/query'
      require 'chef/knife/ssh'
      Chef::Knife::Ssh.load_deps
    end

    banner "knife stop QUERY (options)"

    option :concurrency,
      :short => "-C NUM",
      :long => "--concurrency NUM",
      :description => "The number of concurrent connections",
      :default => 10,
      :proc => lambda { |o| o.to_i }

    def run
      if name_args.size == 0
        $stderr.puts "No query given."
        exit 1
      end

      command = "/usr/bin/sudo -i /usr/bin/env LANG=en_US.UTF-8 systemctl stop chef-client.timer"

      knife_ssh = Chef::Knife::Ssh.new
      knife_ssh.name_args = [name_args.join(" "), command]
      knife_ssh.config[:manual] = false
      knife_ssh.config[:concurrency] = config[:concurrency] unless config[:concurrency] == 0
      knife_ssh.run
    end
  end
end
