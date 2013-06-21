actions :create

attribute :path, :kind_of => String, :name_attribute => true
attribute :user, :kind_of => String, :required => true
attribute :command, :kind_of => String, :required => true
attribute :cwd, :kind_of => String, :required => true
attribute :environment, :kind_of => Hash, :default => {}
attribute :jvm_opts, :kind_of => [Array, String], :default => []

def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end
