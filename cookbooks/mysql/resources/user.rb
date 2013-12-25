actions :create, :delete
default_action :create

attribute :host, kind_of: String, default: "localhost"
attribute :password, kind_of: String, default: nil
attribute :force_password, kind_of: [TrueClass, FalseClass], default: false
