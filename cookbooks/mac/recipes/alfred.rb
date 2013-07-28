if platform?("mac_os_x")
  mac_package "Alfred" do
    source "http://cachefly.alfredapp.com/alfred_1.3.1_261.dmg"
    volumes_dir "Alfred.app"
  end
end
