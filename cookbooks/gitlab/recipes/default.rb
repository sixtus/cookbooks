## gitlab user account
group "git"

account "git" do
  comment "gitlab"
  home "/var/lib/git"
  home_mode "0755"
  gid "git"
end

rvm_instance "git"

rvm_default_ruby "ruby-2.0.0-p0" do
  user "git"
end

rvm_wrapper "git-default" do
  prefix "default"
  ruby_string "default"
  binaries %w(bundle)
  user "git"
end

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

## directory layout
%w(
  /var/lib/git/backups
  /var/lib/git/gitlab
  /var/lib/git/gitlab/shared
  /var/lib/git/gitlab/shared/config
  /var/lib/git/gitlab/shared/log
  /var/lib/git/gitlab/shared/pids
  /var/lib/git/satellites
).each do |dir|
  directory dir do
    owner "git"
    group "git"
    mode "0755"
  end
end

## gitlab-shell
git "/var/lib/git/gitlab-shell" do
  repository "https://github.com/gitlabhq/gitlab-shell.git"
  reference "v1.1.0"
end

template "/var/lib/git/gitlab-shell/config.yml" do
  source "config.yml"
  user "git"
  group "git"
  mode "0644"
end

execute "gitlab-shell-install" do
  command "su -l -c 'cd /var/lib/git/gitlab-shell && ./bin/install >/dev/null' git"
  user "root"
  not_if { File.exist?("/var/lib/git/gitlab-shell/.installed") }
end

file "/var/lib/git/gitlab-shell/.installed"

## gitlab
%w(
  database.yml
  gitlab.yml
  unicorn.rb
).each do |file|
  template "/var/lib/git/gitlab/shared/config/#{file}" do
    source file
    owner "git"
    group "git"
    mode "640"
    variables({
      postgres_password: postgres_password,
    })
  end
end

systemd_user_session "git"

unicorn = systemd_user_unit "unicorn.service" do
  template "unicorn.service"
  user "git"
  action [:create, :enable]
  supports [:reload]
end

sidekiq = systemd_user_unit "sidekiq.service" do
  template "sidekiq.service"
  user "git"
  action [:create, :enable]
end

deploy_branch "/var/lib/git/gitlab" do
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
      code "bundle install --path /var/lib/git/gitlab/shared/bundle --quiet --deployment --without 'development test mysql'"
      cwd release_path
      user "git"
    end

    rvm_shell "gitlab-setup" do
      code "bundle exec rake gitlab:setup force=yes RAILS_ENV=production"
      cwd release_path
      user "git"
      not_if { File.exist?("/var/lib/git/gitlab/shared/.seeded") }
    end

    file "/var/lib/git/gitlab/shared/.seeded"

    rvm_shell "gitlab-migrate" do
      code "bundle exec rake db:migrate RAILS_ENV=production"
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

nginx_unicorn "gitlab" do
  homedir "/var/lib/git/gitlab"
  port 80
end

shorewall_rule "gitlab" do
  destport "http,https"
end

shorewall6_rule "gitlab" do
  destport "http,https"
end
