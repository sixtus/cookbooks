if platform?("mac_os_x")
  mac_package "Install Spotify" do
    source "http://download.spotify.com/SpotifyInstaller.zip"
    type "zip_app"
    not_if { File.exist?("/Applications/Spotify.app") }
  end

  execute "install-spotify" do
    command "open '/Applications/Install Spotify.app'"
    not_if { File.exist?("/Applications/Spotify.app") }
  end
end
