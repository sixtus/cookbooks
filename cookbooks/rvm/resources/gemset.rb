actions :create, :delete, :empty, :update

attribute :gemset, :kind_of => String, :name_attribute => true
attribute :ruby_string, :kind_of => String, :regex => /^[^@]+$/
attribute :user, :kind_of => String

def initialize(*args)
  super
  @action = :create
end
