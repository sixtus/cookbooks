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

## homedir
homedir = "/var/app/gitlab"

deploy_skeleton "git" do
  authorized_keys_for false
end

# gitlab-shell
include_recipe "gitlab::shell"

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

systemd_user_session "git" do
  action :disable
end

systemd_unit "gitlab-unicorn.service" do
  template true
  variables({
    homedir: homedir,
  })
end

systemd_unit "gitlab-sidekiq.service" do
  template true
  variables({
    homedir: homedir,
  })
end

deploy_ruby_application "git" do
  repository "https://github.com/gitlabhq/gitlabhq.git"
  revision "5-0-stable"

  ruby_version "ruby-2.0.0-p0"

  symlink_before_migrate({
    "config/database.yml" => "config/database.yml",
    "config/gitlab.yml" => "config/gitlab.yml",
    "config/unicorn.rb" => "config/unicorn.rb",
  })

  after_bundle do
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

  notifies :reload, "service[gitlab-unicorn]", :immediately
  notifies :restart, "service[gitlab-sidekiq]", :immediately
end

service "gitlab-unicorn" do
  action [:enable, :start]
  supports [:reload]
end

service "gitlab-sidekiq" do
  action [:enable, :start]
end

## nginx proxy
nginx_server "gitlab" do
  template "nginx.conf"
  homedir homedir
end

## open ports
shorewall_rule "gitlab" do
  destport "http,https"
end

shorewall6_rule "gitlab" do
  destport "http,https"
end
