actions [:notify, :nothing]
default_action :notify

attribute :path, kind_of: String, name_attribute: true
attribute :token, kind_of: String, required: true
attribute :env, kind_of: String, required: true
attribute :revision, kind_of: String
attribute :comment, kind_of: String
attribute :command, kind_of: String
