case node[:platform]
when "gentoo"
  package "dev-libs/openssl"
  package "app-misc/ca-certificates"

when "debian"
  package "openssl"
  package "ca-certificates"

end

template "/etc/ssl/openssl.cnf" do
  source "openssl.cnf"
  owner "root"
  group "root"
  mode "0644"
end

if root?
  ssl_certificate "/etc/ssl/certs/wildcard.#{node[:chef_domain]}" do
    cn "wildcard.#{node[:chef_domain]}"
  end

  ruby_block "cleanup-ca-certificates" do
    block do
      Find.find('/etc/ssl/certs') do |path|
        if File.symlink?(path) and not File.exist?(path)
          File.unlink(path)
        end
      end
    end

    only_if do
      require 'find'

      result = false

      Find.find('/etc/ssl/certs') do |path|
        result = true if File.symlink?(path) and not File.exist?(path)
      end

      result
    end
  end
end

if tagged?("nagios-client")
  nagios_plugin "check_ssl_server"
end
