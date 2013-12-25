actions :create, :delete
default_action :create

attribute :owner, kind_of: String
attribute :owner_host, kind_of: String, default: "localhost"
