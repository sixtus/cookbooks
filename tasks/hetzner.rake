# remote commands for maintenance

require 'hetzner-api'

def hetzner
  @hetzner ||= Hetzner::API.new(HETZNER_API_USERNAME, HETZNER_API_PASSWORD)
end

namespace :hetzner do

  desc "reset machine via Hetzner Robot"
  task :reset, :fqdn do |t, args|
    search("fqdn:#{args.fqdn}") do |node|
      hetzner.reset!(node[:primary_ipaddress], :hw)
      wait_for_ssh(node[:fqdn])
    end
  end

  desc "Set server names and reverse DNS"
  task :dns do
    search("*:*") do |node|
      fqdn = node[:fqdn]
      name = fqdn.sub(/\.#{node[:chef_domain]}$/, '')
      ip = Resolv.getaddress(fqdn)

      if ip != node[:primary_ipaddress]
        puts "IP #{node[:primary_ipaddress]} does not match resolved address #{ip} for FQDN #{fqdn}"
      end

      server = hetzner.server?(ip)

      if server['error']
        puts "not a hetzner machine!"
        next
      end

      puts "Setting server name for #{ip} to #{name}"
      hetzner.server!(ip, server_name: name)
      puts "Setting reverse DNS for #{ip} to #{fqdn}"
      hetzner.rdns!(ip, fqdn)
    end
  end

end
