if platform?("mac_os_x")
  mac_package "Spotify" do
    source "http://www.spotify.com/de/download/now/"
    zip true
  end
end
