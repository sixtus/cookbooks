if gentoo?
  portage_package_use "gnome-base/librsvg" do
    use %w(-gtk)
  end

  package "media-gfx/imagemagick"
elsif mac_os_x?
  package "imagemagick"
end
