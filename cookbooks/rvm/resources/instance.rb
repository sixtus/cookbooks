actions :create, :delete

attribute :version, :kind_of => String, :default => "1.21.15"

def initialize(name, run_context=nil)
  super
  @action = :create
end
