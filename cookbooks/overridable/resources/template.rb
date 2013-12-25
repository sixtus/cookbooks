actions :create
default_action :create

attribute :backup, kind_of: [Integer, FalseClass]
attribute :cookbook, kind_of: String, required: true
attribute :group, kind_of: String
attribute :instance, kind_of: String, required: true
attribute :local, kind_of: [TrueClass, FalseClass]
attribute :mode
attribute :owner, kind_of: String
attribute :path, kind_of: String, name_attribute: true
attribute :source, kind_of: String
attribute :variables, kind_of: Hash
