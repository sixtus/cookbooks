def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create, :delete, :start, :stop, :restart, :reload, :enable, :disable

attribute :user, kind_of: String, required: true
attribute :cookbook, kind_of: String
attribute :template, kind_of: String
