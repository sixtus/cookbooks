def ovh
  @ovh ||= OVH::REST.new($conf.ovh.app_key, $conf.ovh.app_secret, $conf.ovh.consumer_key)
end

def ovh_servers
  @ovh_servers ||= ovh.get('/dedicated/server').inject({}) do |h, sn|
    s = ovh.get("/dedicated/server/#{sn}")
    h[s['ip']] = s
    h
  end
end

def ovh_reset(ipaddress)
  name = ovh_servers[ipaddress]['name']
  ovh.post("/dedicated/server/#{name}/reboot")
end

def ovh_enable_rescue_wait(ipaddress)
  name = ovh_servers[ipaddress]['name']
  puts "Putting #{name} into rescue mode"
  ovh.put("/dedicated/server/#{name}", 'bootId' => 22, 'monitoring' => false)
  ovh.put("/dedicated/server/#{name}/serviceInfos", 'renew' => {'automatic' => true, 'forced' => false, 'period' => 1, 'deleteAtExpiration' => false})
  ovh_reset(ipaddress)
  wait_for_ssh(name, false)
  ovh.put("/dedicated/server/#{name}", 'bootId' => 1)
end

def ovh_server_name_rdns(ip, fqdn)
  return unless $conf.ovh && $conf.ovh.consumer_key

  server = ovh_servers[ip]

  if server.nil?
    puts "#{fqdn} not a ovh machine!"
    return
  end

  result = ovh.get("/ip/#{ip}/reverse/#{ip}") rescue {}
  expected = "#{fqdn}."

  if result['reverse'] != expected
    ovh.post("/ip/#{ip}/reverse", 'ipReverse' => ip, 'reverse' => "#{fqdn}.")
    puts "Set reverse for #{fqdn} to #{ip}"
  end
end

def ovh_expire(ipaddress)
  name = ovh_servers[ipaddress]['name']
  puts "Canceling #{name}"
  puts ovh.put("/dedicated/server/#{name}/serviceInfos", 'renew' => {'automatic' => false, 'deleteAtExpiration' => true, 'forced' => false})
end
