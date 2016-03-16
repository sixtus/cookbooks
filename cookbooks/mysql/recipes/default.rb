if gentoo?
  include_recipe "nepal::overlay"

  package "dev-db/mysql"

elsif mac_os_x?
  package "mysql" do
    action :upgrade
  end

end
