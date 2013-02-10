case node[:platform]
when "gentoo"
  portage_package_use "gnome-base/librsvg" do
    use %w(-gtk)
  end

  package "media-gfx/imagemagick"

when "mac_os_x"
  package "imagemagick"

end
