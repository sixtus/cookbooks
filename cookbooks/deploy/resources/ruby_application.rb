actions :create

attribute :user, :kind_of => String, :name_attribute => true
attribute :repository, :kind_of => String, :required => true
attribute :revision, :kind_of => String, :required => true
attribute :rvm_version, :kind_of => String
attribute :ruby_version, :kind_of => String, :required => true
attribute :symlink_before_migrate, :kind_of => Hash, :default => {}
attribute :symlinks, :kind_of => Hash, :default => {}
attribute :bundle_without, :kind_of => [Array, String], :default => %w(development test)
attribute :force, :kind_of => [TrueClass, FalseClass], :default => false

def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

def before_restart(arg=nil, &block)
  arg ||= block
  set_or_return(:before_restart, arg, :kind_of => [Proc, String])
end

def after_bundle(arg=nil, &block)
  arg ||= block
  set_or_return(:after_bundle, arg, :kind_of => [Proc, String])
end
