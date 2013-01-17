package "app-office/openerp"

group "postgres" do
  action :modify
  members "openerp"
  append true
end

admin_password = get_password("openerp/admin")

# create user and database with:
# createuser --createdb --pwprompt --superuser --no-createrole --username postgres openerp
db_password = get_password("openerp/db")

template "/etc/openerp/openerp.cfg" do
  source "openerp.cfg"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[openerp]"
  variables :admin_password => admin_password,
            :db_password => db_password
end

service "openerp" do
  action [:enable, :start]
end
