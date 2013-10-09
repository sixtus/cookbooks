actions :create, :delete

attribute :version, :kind_of => String, :default => "1.22.2"

def initialize(name, run_context=nil)
  super
  @action = :create
end
