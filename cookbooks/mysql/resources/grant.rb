actions :create, :delete
default_action :create

attribute :privileges, kind_of: [String, Array], default: "ALL"
attribute :database, kind_of: String, required: true
attribute :user, kind_of: String, required: true
attribute :user_host, kind_of: String, default: "localhost"
attribute :grant_option, kind_of: [TrueClass, FalseClass], default: false
