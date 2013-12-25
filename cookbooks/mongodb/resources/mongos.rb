actions :create, :delete
default_action :create

attribute :bind_ip, kind_of: String, default: "127.0.0.1"
attribute :port, kind_of: Fixnum, default: 27217

def initialize(*args)
  super
  @run_context.include_recipe "mongodb"
end
