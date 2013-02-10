case node[:platform]
when "gentoo"
  package "dev-db/mysql"

when "mac_os_x"
  package "mysql" do
    action :upgrade
  end

end
