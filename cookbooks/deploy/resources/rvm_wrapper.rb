actions :create
default_action :create

attribute :path, :kind_of => String, :name_attribute => true
attribute :user, :kind_of => String, :required => true
attribute :command, :kind_of => String, :required => true
attribute :cwd, :kind_of => String, :required => true
attribute :environment, :kind_of => Hash, :default => {}
