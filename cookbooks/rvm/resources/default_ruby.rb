actions :create

attribute :ruby_string, :kind_of => String, :name_attribute => true
attribute :user,        :kind_of => String

def initialize(*args)
  super
  @action = :create
end
