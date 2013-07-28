portage_package_use "dev-db/mongodb" do
  use %w(-v8)
end

package "dev-db/mongodb"
package "dev-python/pymongo"
package "dev-ruby/mongo"

file "/etc/logrotate.d/mongodb" do
  action :delete
end

if tagged?("nagios-client")
  nagios_plugin "check_mongodb"
end

systemd_tmpfiles "mongodb"

node[:mongos][:instances].each do |cluster, params|
  mongodb_mongos cluster do
    bind_ip params[:bind_ip]
    port params[:port]
  end
end
