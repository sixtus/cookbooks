include ChefUtils::Account

action :create do
  nr = new_resource # rebind
  user = nr.name
  path = get_user(user)[:dir]

  rvm_instance user do
    version nr.rvm_version if nr.rvm_version
  end

  rvm_default_ruby "#{user}-#{nr.ruby_version}" do
    ruby_string nr.ruby_version
    user user
  end

  rvm_wrapper "#{user}-default" do
    prefix "default"
    ruby_string "default"
    binaries %w(bundle)
    user user
  end

  paths = [
    "#{path}/shared/bundle",
  ]

  portage_preserve_libs user do
    paths paths
  end
end
