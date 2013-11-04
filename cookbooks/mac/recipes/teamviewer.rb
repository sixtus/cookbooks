if mac_os_x?
  mac_package "Install TeamViewer" do
    source "http://download.teamviewer.com/download/TeamViewer.dmg"
    type "dmg_pkg"
    volumes_dir "TeamViewer"
    not_if { File.exist?("/Applications/TeamViewer 8") }
  end
end
