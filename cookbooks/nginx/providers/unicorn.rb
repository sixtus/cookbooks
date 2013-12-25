include ChefUtils::Account

use_inline_resources

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  path = nr.path || nr.homedir || user[:dir]
  port = nr.port.to_i

  nginx_server "unicorn-#{nr.name}" do
    template "unicorn.conf"
    cookbook "nginx"
    user user[:name]
    path path
    port port
  end
end
