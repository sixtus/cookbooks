include_recipe "postgresql::server"

package "app-office/openerp"

group "postgres" do
  action :modify
  members "openerp"
  append true
end

admin_password = get_password("openerp/admin")
db_password = get_password("openerp/db")

postgresql_role "openerp" do
  password db_password
  superuser true
  createdb true
  createrole true
  inherit true
  login true
end

postgresql_database "openerp"

template "/etc/openerp/openerp.cfg" do
  source "openerp.cfg"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[openerp]"
  variables :admin_password => admin_password,
            :db_password => db_password
end

systemd_unit "openerp.service"

service "openerp" do
  action [:enable, :start]
end

shorewall_rule "openerp" do
  destport "8069"
end
