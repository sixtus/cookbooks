actions :create, :delete
default_action :create

attribute :package, kind_of: String, name_attribute: true
attribute :keywords, kind_of: [String, Array]

def initialize(*args)
  super
  @run_context.include_recipe("portage")
end
