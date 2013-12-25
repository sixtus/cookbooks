actions :create
default_action :create

attribute :source, kind_of: String, name_attribute: true
attribute :cookbook, kind_of: String, default: ""
