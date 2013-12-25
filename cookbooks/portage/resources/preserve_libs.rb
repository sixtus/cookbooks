actions :create
default_action :create

attribute :paths, kind_of: [String, Array], required: true

def initialize(*args)
  super
  @run_context.include_recipe("portage")
end
