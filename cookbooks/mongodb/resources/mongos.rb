def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

actions :create, :delete

attribute :bind_ip, :kind_of => String, :default => "127.0.0.1"
attribute :port, :kind_of => Fixnum, :default => 27217
