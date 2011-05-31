def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create

attribute :version, :kind_of => String, :default => "3.4.0"
attribute :environment, :kind_of => String, :default => "production"
attribute :config, :kind_of => Hash, :default => []
attribute :bundler, :kind_of => [TrueClass, FalseClass], :default => true
