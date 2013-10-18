actions :create, :delete
default_action :create

attribute :user, kind_of: String, name_attribute: true
attribute :path, kind_of: String, default: nil
attribute :homedir, kind_of: String, default: nil
attribute :port, kind_of: [Fixnum, String], required: true
