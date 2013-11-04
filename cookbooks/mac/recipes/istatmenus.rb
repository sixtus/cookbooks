if platform?("mac_os_x")
  mac_package "iStat Menus" do
    source "http://s3.amazonaws.com/bjango/files/istatmenus3/istatmenus3.27.zip"
    type "zip_app"
  end
end
