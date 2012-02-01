if platform?("mac_os_x")
  package "imagemagick"
else
  portage_package_use "gnome-base/librsvg" do
    use %w(-gtk)
  end

  package "media-gfx/imagemagick"
end
