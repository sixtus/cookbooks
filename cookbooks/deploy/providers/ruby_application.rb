include ChefUtils::Account

action :create do
  user = get_user(new_resource.user)
  homedir = user[:dir]
  nr = new_resource # rebind

  deploy_rvm_ruby user[:name] do
    ruby_version nr.ruby_version
  end

  deploy_branch homedir do
    repository nr.repository
    revision nr.revision
    user nr.user

    action :force_deploy if nr.force

    symlink_before_migrate({
      "config/database.yml" => "config/database.yml",
      "config/gitlab.yml" => "config/gitlab.yml",
      "config/unicorn.rb" => "config/unicorn.rb",
    })

    before_symlink do
      rvm_shell "gitlab-bundle-install" do
        code "bundle install --path #{homedir}/shared/bundle --quiet --deployment --without '#{[nr.bundle_without].flatten.join(' ')}'"
        cwd release_path
        user nr.user
      end

      callback(:after_bundle, nr.after_bundle)
    end
  end
end
