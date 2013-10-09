include ChefUtils::Account

use_inline_resources rescue nil

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  homedir = user[:dir]

  deploy_rvm_ruby user[:name] do
    rvm_version nr.rvm_version
    ruby_version nr.ruby_version
  end

  deploy_application user[:name] do
    repository nr.repository
    revision nr.revision
    user nr.user

    force nr.force

    purge_before_symlink nr.purge_before_symlink
    symlink_before_migrate nr.symlink_before_migrate
    symlinks nr.symlinks

    before_migrate do
      rvm_shell "#{nr.user}-bundle-install" do
        code "bundle install --path #{homedir}/shared/bundle --quiet --deployment --without '#{[nr.bundle_without].flatten.join(' ')}'"
        cwd release_path
        user nr.user
      end

      ruby_block "#{nr.user}-after-bundle" do
        block do
          callback(:after_bundle, nr.after_bundle)
        end
      end
    end

    before_symlink nr.before_symlink
    before_restart nr.before_restart
  end
end
