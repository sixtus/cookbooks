actions :create, :delete
default_action :create

attribute :template, kind_of: String, required: false
attribute :cookbook, kind_of: String, required: false
attribute :sapi, kind_of: [String, Array], required: false, default: "all"
