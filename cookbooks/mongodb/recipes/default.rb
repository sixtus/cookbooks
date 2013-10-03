case node[:platform]
when "gentoo"
  package "dev-db/mongodb"
  package "dev-python/pymongo"
  package "dev-ruby/mongo"

  if root?
    file "/etc/logrotate.d/mongodb" do
      action :delete
    end

    nagios_plugin "check_mongodb"

    systemd_tmpfiles "mongodb"

    node[:mongos][:instances].each do |cluster, params|
      mongodb_mongos cluster do
        bind_ip params[:bind_ip]
        port params[:port]
      end
    end
  end

when "mac_os_x"
  package "mongodb"
end
