begin
  require 'hetzner-api'
rescue LoadError
  $stderr.puts "Hetzner API cannot be loaded. Skipping some rake tasks ..."
end

def hetzner
  @hetzner ||= Hetzner::API.new(HETZNER_API_USERNAME, HETZNER_API_PASSWORD)
end

def hetzner_server_name_rdns(ip, name, fqdn)
  return unless ::Module.const_defined?(:HETZNER_API_USERNAME)

  server = hetzner.server?(ip)

  if server['error']
    puts "not a hetzner machine!"
    return
  end

  puts "Setting server name for #{ip} to #{name}"
  hetzner.server!(ip, server_name: name)
  puts "Setting reverse DNS for #{ip} to #{fqdn}"
  hetzner.rdns!(ip, fqdn)
end
