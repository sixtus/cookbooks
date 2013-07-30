def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create, :delete

attribute :template, kind_of: [TrueClass, String], default: nil
attribute :variables, kind_of: Hash, default: {}
attribute :cookbook, kind_of: String, default: nil
