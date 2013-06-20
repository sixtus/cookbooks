actions :create, :delete

attribute :version, :kind_of => String, :default => "1.20.13"

def initialize(name, run_context=nil)
  super
  @action = :create
end
