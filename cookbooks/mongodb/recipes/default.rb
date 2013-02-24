portage_package_use "dev-db/mongodb" do
  use %w(-v8)
end

package "dev-db/mongodb"
package "dev-python/pymongo"
package "dev-ruby/mongo"

file "/etc/logrotate.d/mongodb" do
  action :delete
  not_if { node[:mongodb][:instances]["mongodb"] rescue false }
end

if tagged?("nagios-client")
  nagios_plugin "check_mongodb"
end
