include ChefUtils::Account

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  homedir = user[:dir]

  deploy_branch homedir do
    repository nr.repository
    revision nr.revision
    user nr.user

    action :force_deploy if nr.force

    symlinks nr.symlinks
    symlink_before_migrate nr.symlink_before_migrate

    before_symlink nr.before_symlink
    before_restart nr.before_restart
  end
end
