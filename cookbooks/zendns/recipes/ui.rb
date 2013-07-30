include_recipe "nodejs"

homedir = "/var/app/zendns"

deploy_skeleton "zendns"

%w(
  devise.rb
  domains.rb
  production.rb
).each do |file|
  template "#{homedir}/shared/config/#{file}" do
    source file
    owner "zendns"
    group "zendns"
    mode "640"
  end
end

systemd_user_session "zendns" do
  action :disable
end

systemd_unit "zendns-unicorn.service" do
  template true
  variables({
    homedir: homedir,
  })
end

deploy_rails_application "zendns" do
  repository "https://github.com/zenops/zendns.git"
  revision "master"

  ruby_version "ruby-2.0.0-p247"

  worker_processes node[:zendns][:ui][:worker_processes]
  timeout node[:zendns][:ui][:timeout]

  symlink_before_migrate({
    # shared => current
    "config/devise.rb" => "config/initializers/devise.rb",
    "config/domains.rb" => "config/initializers/domains.rb",
    "config/production.rb" => "config/environments/production.rb",
  })

  notifies :reload, "service[zendns-unicorn]", :immediately
end

service "zendns-unicorn" do
  action [:enable, :start]
  supports [:reload]
end

ssl_certificate "/etc/ssl/nginx/zendns" do
  cn node[:zendns][:ui][:host]
end

nginx_server "zendns" do
  template "nginx.conf"
  homedir homedir
end

shorewall_rule "zendns-ui" do
  destport "http,https"
end
