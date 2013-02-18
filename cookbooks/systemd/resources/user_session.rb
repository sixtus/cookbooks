def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :enable
end

actions :enable, :disable
