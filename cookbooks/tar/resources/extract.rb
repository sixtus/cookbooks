actions :extract
default_action :extract

attribute :source, kind_of: String, name_attribute: true
attribute :download_dir, kind_of: String, default: Chef::Config[:file_backup_path]
attribute :target_dir, kind_of: String
attribute :user, kind_of: String
attribute :group, kind_of: String
attribute :creates, kind_of: String
