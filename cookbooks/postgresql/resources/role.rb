def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create

attribute :role, :kind_of => String, :name_attribute => true
attribute :password, :kind_of => String
attribute :superuser, :default => false
attribute :createdb, :default => false
attribute :createrole, :default => false
attribute :inherit, :default => false
attribute :login, :default => false
attribute :exists, :default => false
