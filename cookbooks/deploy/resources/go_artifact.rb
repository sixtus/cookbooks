actions :create
default_action :create

attribute :user, kind_of: String, name_attribute: true
attribute :remote_path, kind_of: String
attribute :bucket, kind_of: String
attribute :aws_access_key_id, kind_of: String, default: nil
attribute :aws_secret_access_key, kind_of: String, default: nil
attribute :s3_url, kind_of: String, default: nil
attribute :token, kind_of: String, default: nil
