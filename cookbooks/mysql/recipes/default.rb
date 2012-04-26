if platform?("mac_os_x")
  package "mysql" do
    action :upgrade
    notifies :run, "execute[mysql-link-plist]"
  end
else
  package "dev-db/mysql"
end
