## databases
include_recipe "redis"
include_recipe "postgresql::server"

postgres_password = get_password("postgresql/gitlabci")

postgresql_role "gitlabci" do
  password postgres_password
  login true
end

postgresql_database "gitlabci_production" do
  owner "gitlabci"
end

## user & rvm
homedir = "/var/app/gitlabci"

deploy_skeleton "gitlabci" do
  homedir homedir
end

deploy_rvm_ruby "gitlabci" do
  ruby_version "ruby-2.0.0-p0"
end

## gitlab ci
%w(
  database.yml
  unicorn.rb
).each do |file|
  template "#{homedir}/shared/config/#{file}" do
    source "ci/#{file}"
    owner "git"
    group "git"
    mode "640"
    variables({
      postgres_password: postgres_password,
      homedir: homedir
    })
  end
end

systemd_user_session "gitlabci"

unicorn = systemd_user_unit "gitlabci-unicorn.service" do
  unit "unicorn.service"
  template "unicorn.service"
  user "gitlabci"
  action [:create, :enable]
  supports [:reload]
  variables({
    homedir: homedir,
  })
end

sidekiq = systemd_user_unit "gitlabci-sidekiq.service" do
  unit "sidekiq.service"
  template "ci/sidekiq.service"
  user "gitlabci"
  action [:create, :enable]
  variables({
    homedir: homedir,
  })
end

deploy_branch homedir do
  repository "https://github.com/gitlabhq/gitlab-ci.git"
  revision "2-1-stable"
  user "gitlabci"

  symlink_before_migrate({
    "config/database.yml" => "config/database.yml",
    "config/unicorn.rb" => "config/unicorn.rb",
  })

  before_symlink do
    rvm_shell "gitlabci-bundle-install" do
      code "bundle install --path #{homedir}/shared/bundle --quiet --deployment --without 'development test mysql'"
      cwd release_path
      user "gitlabci"
    end

    rvm_shell "gitlabci-setup" do
      code "bundle exec rake db:setup RAILS_ENV=production"
      cwd release_path
      user "gitlabci"
      not_if { File.exist?("#{homedir}/shared/.seeded") }
    end

    file "#{homedir}/shared/.seeded"

    rvm_shell "gitlabci-migrate" do
      code "bundle exec rake db:migrate RAILS_ENV=production"
      cwd release_path
      user "gitlabci"
    end

    rvm_shell "gitlabci-assets" do
      code "bundle exec rake assets:precompile RAILS_ENV=production"
      cwd release_path
      user "gitlabci"
    end
  end

  after_restart do
    unicorn.run_action(:reload)
    unicorn.run_action(:start)
    sidekiq.run_action(:restart)
    sidekiq.run_action(:start)
  end
end

nginx_server "gitlabci" do
  template "ci/nginx.conf"
  homedir homedir
end

shorewall_rule "gitlabci" do
  destport "http,https"
end

shorewall6_rule "gitlabci" do
  destport "http,https"
end

if tagged?("nagios-client")
  nrpe_command "check_gitlabci_unicorn" do
    command "/usr/lib/nagios/plugins/check_pidfile #{homedir}/shared/pids/unicorn.pid"
  end

  nagios_service "GITLABCI-UNICORN" do
    check_command "check_nrpe!check_gitlabci_unicorn"
    servicegroups name
  end
end
