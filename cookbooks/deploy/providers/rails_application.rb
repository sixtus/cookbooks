include ChefUtils::Account

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  homedir = user[:dir]

  template "#{homedir}/shared/config/unicorn.rb" do
    source "rails/unicorn.rb"
    cookbook "deploy"
    owner user[:name]
    group user[:group][:name]
    mode "640"
    variables({
      homedir: homedir,
      worker_processes: nr.worker_processes,
      timeout: nr.timeout,
    })
  end

  deploy_ruby_application user[:name] do
    repository nr.repository
    revision nr.revision
    user nr.user

    rvm_version nr.rvm_version
    ruby_version nr.ruby_version

    force nr.force

    symlinks nr.symlinks
    symlink_before_migrate({
      "config/unicorn.rb" => "config/unicorn.rb",
    }.merge(nr.symlink_before_migrate))

    after_bundle nr.after_bundle
    before_restart nr.before_restart
  end
end
