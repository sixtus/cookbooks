def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create, :create_if_missing

attribute :backup, :kind_of => [ Integer, FalseClass ]
attribute :checksum, :regex => /^[a-zA-Z0-9]{64}$/
attribute :cookbook, :kind_of => String
attribute :group, :kind_of => String
attribute :local, :kind_of => [ TrueClass, FalseClass ]
attribute :mode
attribute :only_if_missing, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :owner, :kind_of => String
attribute :path, :kind_of => String, :name_attribute => true
attribute :source, :kind_of => String
attribute :variables, :kind_of => Hash

attribute :namespace, :kind_of => [ String, Symbol ]
attribute :instance
