include ChefUtils::Account

action :create do
  user = new_resource.name
  homedir = get_user(user)[:homedir]

  rvm_instance user

  rvm_default_ruby new_resource.ruby_version do
    user user
  end

  rvm_wrapper "#{user}-default" do
    prefix "default"
    ruby_string "default"
    binaries %w(bundle)
    user user
  end

  paths = [
    "#{homedir}/.rvm/rubies",
    "#{homedir}/.rvm/gems",
    "#{homedir}/shared/bundle",
  ]

  portage_preserve_libs user do
    paths paths
  end
end
