mac_package "Google Chrome" do
  source "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
  only_if { mac_os_x? }
end
