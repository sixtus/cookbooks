# remote commands for maintenance

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

      hetzner_server_name_rdns(ip, name, fqdn)
    end
  end

end
