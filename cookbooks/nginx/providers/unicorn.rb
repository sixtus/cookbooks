include ChefUtils::Account

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  path = nr.path || user[:dir]
  port = nr.port

  nginx_server "unicorn-#{nr.name}" do
    template "unicorn.conf"
    cookbook "nginx"
    user user[:name]
    path path
    port port
  end
end
