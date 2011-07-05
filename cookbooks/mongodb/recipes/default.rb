package "dev-db/mongodb" do
  use "-v8"
end

if tagged?("nagios-client")
  package "dev-python/pymongo"

  nagios_plugin "mongodb" do
    source "check_mongodb"
  end
end
