include ChefUtils::Account

use_inline_resources

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  path = user[:dir]
  revision = nr.revision || node.chef_environment

  # simple support for vagrant specific branches
  if vagrant?
    revision = "vagrant/#{node[:hostname]}"
    remote = %x(sudo -H -u #{nr.user} git ls-remote --heads #{nr.repository} #{revision}).chomp
    revision = "production" if remote.empty?
  end

  deploy_branch path do
    repository nr.repository
    revision revision
    user nr.user

    action :force_deploy if nr.force

    purge_before_symlink nr.purge_before_symlink
    symlink_before_migrate nr.symlink_before_migrate
    symlinks nr.symlinks

    migrate true
    migration_command "/bin/true" # use callbacks for actual work

    before_migrate nr.before_migrate
    before_symlink nr.before_symlink
    before_restart nr.before_restart
  end
end
