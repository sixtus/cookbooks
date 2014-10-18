actions :create, :delete
default_action :create

attribute :version, kind_of: String, default: "1.25.27"
attribute :update, kind_of: [FalseClass, TrueClass], default: false
