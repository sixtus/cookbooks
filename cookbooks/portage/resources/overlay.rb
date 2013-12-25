actions :create, :delete
default_action :create

def initialize(*args)
  super
  @run_context.include_recipe("portage::layman")
end
