include ChefUtils::Account

use_inline_resources rescue nil

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  homedir = user[:dir]

  deploy_branch homedir do
    repository nr.repository
    revision nr.revision
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
