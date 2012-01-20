if platform?("gentoo")
  package "dev-libs/openssl"
  package "app-misc/ca-certificates"

  template "/etc/ssl/openssl.cnf" do
    source "openssl.cnf.erb"
    owner "root"
    group "root"
    mode "0644"
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
        if File.symlink?(path) and not File.exist?(path)
          result = true
        end
      end

      result
    end
  end

  nagios_plugin "check_ssl_server"
end
