## databases
include_recipe "redis"
include_recipe "postgresql::server"

postgres_password = get_password("postgresql/gitlab")

postgresql_role "gitlab" do
  password postgres_password
  login true
end

postgresql_database "gitlab_production" do
  owner "gitlab"
end

## user & rvm
homedir = "/var/app/gitlab"

deploy_skeleton "git" do
  homedir homedir
end

deploy_rvm_ruby "git" do
  ruby_version "ruby-2.0.0-p0"
end

## gitlab-shell
%w(
  backups
  satellites
).each do |dir|
  directory "#{homedir}/#{dir}" do
    owner "git"
    group "git"
    mode "0755"
  end
end

git "#{homedir}/gitlab-shell" do
  repository "https://github.com/gitlabhq/gitlab-shell.git"
  reference "v1.2.0"
end

template "#{homedir}/gitlab-shell/config.yml" do
  source "config.yml"
  user "git"
  group "git"
  mode "0644"
  variables({
    homedir: homedir,
  })
end

execute "gitlab-shell-install" do
  command "su -l -c 'cd #{homedir}/gitlab-shell && ./bin/install >/dev/null' git"
  user "root"
  not_if { File.exist?("#{homedir}/gitlab-shell/.installed") }
end

file "#{homedir}/gitlab-shell/.installed"

## gitlab
%w(
  database.yml
  gitlab.yml
  unicorn.rb
).each do |file|
  template "#{homedir}/shared/config/#{file}" do
    source file
    owner "git"
    group "git"
    mode "640"
    variables({
      postgres_password: postgres_password,
      homedir: homedir
    })
  end
end

systemd_user_session "git"

unicorn = systemd_user_unit "unicorn.service" do
  template "unicorn.service"
  user "git"
  action [:create, :enable]
  supports [:reload]
  variables({
    homedir: homedir,
  })
end

sidekiq = systemd_user_unit "sidekiq.service" do
  template "sidekiq.service"
  user "git"
  action [:create, :enable]
  variables({
    homedir: homedir,
  })
end

deploy_branch homedir do
  repository "https://github.com/gitlabhq/gitlabhq.git"
  revision "5-0-stable"
  user "git"

  symlink_before_migrate({
    "config/database.yml" => "config/database.yml",
    "config/gitlab.yml" => "config/gitlab.yml",
    "config/unicorn.rb" => "config/unicorn.rb",
  })

  before_symlink do
    rvm_shell "gitlab-bundle-install" do
      code "bundle install --path #{homedir}/shared/bundle --quiet --deployment --without 'development test mysql'"
      cwd release_path
      user "git"
    end

    rvm_shell "gitlab-setup" do
      code "bundle exec rake gitlab:setup force=yes RAILS_ENV=production"
      cwd release_path
      user "git"
      not_if { File.exist?("#{homedir}/shared/.seeded") }
    end

    file "#{homedir}/shared/.seeded"

    rvm_shell "gitlab-migrate" do
      code "bundle exec rake db:migrate RAILS_ENV=production"
      cwd release_path
      user "git"
    end

    rvm_shell "gitlab-assets" do
      code "bundle exec rake assets:precompile RAILS_ENV=production"
      cwd release_path
      user "git"
    end
  end

  after_restart do
    unicorn.run_action(:reload)
    unicorn.run_action(:start)
    sidekiq.run_action(:restart)
    sidekiq.run_action(:start)
  end
end

nginx_server "gitlab" do
  template "nginx.conf"
  homedir homedir
end

shorewall_rule "gitlab" do
  destport "http,https"
end

shorewall6_rule "gitlab" do
  destport "http,https"
end

if tagged?("nagios-client")
  nrpe_command "check_gitlab_unicorn" do
    command "/usr/lib/nagios/plugins/check_pidfile #{homedir}/shared/pids/unicorn.pid"
  end

  nagios_service "GITLAB-UNICORN" do
    check_command "check_nrpe!check_gitlab_unicorn"
    servicegroups name
  end
end
