include ChefUtils::RVM

action :create do
  rvm = infer_vars(new_resource.name)
  bundle_path = "#{rvm[:homedir]}/shared/bundle"

  rvm_gem "bundler" do
    version new_resource.version
    user rvm[:user]
  end

  directory bundle_path do
    owner rvm[:user]
    group rvm[:group]
    mode "0755"
  end

  portage_preserve_libs "capistrano_bundler-#{rvm[:user]}" do
    paths [bundle_path]
  end
end
