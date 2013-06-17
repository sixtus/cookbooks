actions :create

attribute :repository, :kind_of => String, :required => true
attribute :revision, :kind_of => String, :required => true
attribute :user, :kind_of => String, :required => true
attribute :ruby_version, :kind_of => String, :required => true
attribute :symlink_before_migrate, :kind_of => Hash
attribute :before_symlink, :kind_of => [Proc, String]
attribute :after_restart, :kind_of => [Proc, String]
attribute :after_bundle, :kind_of => [Proc, String]
attribute :bundle_without, :kind_of => [Array, String], :default => %w(development test)
attribute :force, :kind_of => [TrueClass, FalseClass], :default => false

def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end
