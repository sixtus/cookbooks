include AccountHelpers

use_inline_resources

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  path = user[:dir]
  shared_path = "#{path}/shared"

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
    symlink_before_migrate({}) # see below
    symlinks nr.symlinks

    before_migrate do
      # symlink_before_migrate runs _after_ the before_migrate callback chain.
      # some applications rely on these symlinks to setup before_migrate tasks
      nr.symlink_before_migrate.each do |src, dest|
        begin
          FileUtils.ln_sf(shared_path + "/#{src}", release_path + "/#{dest}")
        rescue => e
          raise Chef::Exceptions::FileNotFound.new("Cannot symlink #{shared_path}/#{src} to #{release_path}/#{dest} before migrate: #{e.message}")
        end
      end

      rvm_shell "#{nr.user}-bundle-install" do
        code "bundle install --path #{path}/shared/bundle --quiet --deployment --without '#{[nr.bundle_without].flatten.join(' ')}'"
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
