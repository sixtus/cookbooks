def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create, :delete, :start, :stop, :restart, :reload, :enable, :disable

attribute :unit, kind_of: String, name_attribute: true
attribute :user, kind_of: String, required: true
attribute :cookbook, kind_of: String
attribute :template, kind_of: String
attribute :variables, kind_of: Hash, default: {}
