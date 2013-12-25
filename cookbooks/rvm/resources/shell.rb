actions :run
default_action :run
attribute :name, kind_of: String, name_attribute: true
attribute :ruby_string, kind_of: String, default: "default"
attribute :code, kind_of: String
attribute :creates, kind_of: String
attribute :cwd, kind_of: String
attribute :environment, kind_of: Hash, default: {}
attribute :group, kind_of: String
attribute :path, kind_of: Array
attribute :returns, kind_of: Array, default: [0]
attribute :timeout, kind_of: Integer
attribute :user, kind_of: String
attribute :umask, kind_of: String
