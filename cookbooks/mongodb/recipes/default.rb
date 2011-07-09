portage_package_use "dev-db/mongodb" do
  use %w(-v8)
end

package "dev-db/mongodb"

if tagged?("nagios-client")
  package "dev-python/pymongo"
  nagios_plugin "check_mongodb"
end
