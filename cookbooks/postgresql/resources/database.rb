def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create, :query

attribute :database, :kind_of => String, :name_attribute => true
attribute :owner, :kind_of => String, :default => "postgres"
