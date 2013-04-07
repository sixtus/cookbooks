actions :create

attribute :ruby_version, :kind_of => String, :required => true

def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end
