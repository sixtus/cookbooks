if platform?("mac_os_x")
  package "mysql" do
    action :upgrade
  end
else
  package "dev-db/mysql"
end
