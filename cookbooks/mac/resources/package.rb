actions :install

attribute :app, :kind_of => String, :name_attribute => true
attribute :source, :kind_of => String, :default => nil
attribute :destination, :kind_of => String, :default => "/Applications"
attribute :checksum, :kind_of => String, :default => nil
attribute :volumes_dir, :kind_of => String, :default => nil
attribute :dmg_name, :kind_of => String, :default => nil
attribute :type, :kind_of => String, :default => "dmg_app"
attribute :installed, :kind_of => [TrueClass, FalseClass], :default => false
attribute :package_id, :kind_of => String, :default => nil
attribute :dmg_passphrase, :kind_of => String, :default => nil
attribute :accept_eula, :kind_of => [TrueClass, FalseClass], :default => false

def initialize(name, run_context=nil)
  super
  @action = :install
end
