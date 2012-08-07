if platform?("mac_os_x")
  mac_package "Alfred" do
    source "http://media.alfredapp.com/alfred_1.3_249.dmg"
    volumes_dir "Alfred.app"
  end
end
