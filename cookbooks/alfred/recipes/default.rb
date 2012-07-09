if platform?("mac_os_x")
  mac_package "Alfred" do
    source "http://rwc.cachefly.net/alfred_1.2_220.dmg"
    volumes_dir "Alfred.app"
  end
end
