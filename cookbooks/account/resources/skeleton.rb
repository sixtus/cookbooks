actions :create, :delete
default_action :create

attribute :login, kind_of: String, regex: /^[a-z]+$/, name_attribute: true
attribute :uid, kind_of: Integer
attribute :gid, kind_of: String, default: "users"
attribute :groups, kind_of: Array, default: []
attribute :shell, kind_of: String, default: "/bin/bash"
attribute :comment, kind_of: String
attribute :password, kind_of: String, default: "!"
attribute :home, kind_of: String
attribute :home_mode, kind_of: String, default: "0755"
attribute :home_owner, kind_of: String
attribute :home_group, kind_of: String
attribute :authorized_keys, kind_of: [String, Array]
attribute :authorized_keys_for, kind_of: [String, Array]
attribute :key_source, kind_of: String
