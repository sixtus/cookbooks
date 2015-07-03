begin
  require 'ovh/rest'
  require 'ipaddr'

  namespace :ovh do

    desc "reset machine"
    task :reset, :fqdn do |t, args|
      search("fqdn:#{args.fqdn}") do |node|
        ovh_reset(node[:ipaddress])
        wait_for_ssh(node[:fqdn])
      end
    end

    desc "enable rescue mode, reset machine and login"
    task :rescue, :fqdn do |t, args|
      search("fqdn:#{args.fqdn}") do |node|
        ovh_enable_rescue_wait(node[:ipaddress])
        sshlive(args.fqdn)
      end
    end

    desc "enable rescue mode and reinstall"
    task :reinstall, :fqdn, :ipaddress, :profile do |t, args|
      args.with_defaults(:profile => 'generic-two-disk-md')
      ovh_enable_rescue_wait(args.ipaddress)
      sleep(10) # sleep a while so that boot scripts deploy our ssh key
      run_task('node:quickstart', args.fqdn, args.ipaddress, args.profile)
      run_task('ovh:sync_isp_info', args.fqdn)
      ENV['REBOOT'] = "1"
      run_task('node:updateworld', args.fqdn)

      match = args.fqdn.match(/^(.+?)(\d*)\.(.+?)\./)
      default_role = "role[#{match[3]}-#{match[1]}]"
      knife(:node_run_list_set, [args.fqdn, default_role])
      system("ssh -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' -o 'GlobalKnownHostsFile /dev/null' -t #{args.fqdn} '/usr/bin/sudo -i systemctl reset-failed'")
    end

    desc "set server names and reverse DNS"
    task :dns do
      search("*:*") do |node|
        fqdn = node[:fqdn]
        ip = Resolv.getaddress(fqdn)

        if ip != node[:ipaddress]
          puts "IP #{node[:ipaddress]} does not match resolved address #{ip} for FQDN #{fqdn}"
        end

        ovh_server_name_rdns(ip, fqdn)
      end
    end

    desc "expire a server"
    task :expire, :fqdn do |t, args|
      search("fqdn:#{args.fqdn}") do |node|
        ovh_expire(node[:ipaddress])
      end
    end

    desc "reads ovh properties and writes them to node properties"
    task :sync_isp_info, :host do |t, args|
      hostname = args.host || "*"
      search("fqdn:#{hostname}") do |node|
        ovh_info = ovh_servers[node[:ipaddress]]
        unless ovh_info
          puts "Not an OVH server"
          next
        end

        knife(:node_attribute_set, [node[:fqdn], "hardware.isp", "ovh"])
        %w{datacenter name rack}.each do |config_name|
          value = case config_name
          when 'datacenter'
            ovh_info[config_name][0...-1] # rbx instead of rbx1,rbx2...
          else
            ovh_info[config_name]
          end
          knife(:node_attribute_set, [node[:fqdn], "hardware.#{config_name}", value])
        end

        ovh.get("/dedicated/server/#{ovh_info["name"]}/ips").each do |segment|
          segment = IPAddr.new(segment)
          next unless segment.ipv6?
          ip = segment | IPAddr.new("0000:0000:0000:0000:0000:0000:0000:0001") # first ip for server
          cdir = 64 # ovh convention
          gw = segment | IPAddr.new("0000:0000:0000:00ff:00ff:00ff:00ff:00ff") # ovh convention
          knife(:node_attribute_set, [node[:fqdn], "ipv6.address", ip.to_s])
          knife(:node_attribute_set, [node[:fqdn], "ipv6.cdir", cdir])
          knife(:node_attribute_set, [node[:fqdn], "ipv6.gw", gw.to_s])
        end
      end
    end
  end
rescue LoadError
  $stderr.puts "OVH API cannot be loaded. Skipping some rake tasks ..."
end
