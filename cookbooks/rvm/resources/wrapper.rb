actions :create

attribute :prefix, :kind_of => String, :name_attribute => true
attribute :ruby_string, :kind_of => String
attribute :binary, :kind_of => String
attribute :binaries, :kind_of => Array
attribute :user, :kind_of => String

def initialize(*args)
  super
  @action = :create
end
