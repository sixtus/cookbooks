include_recipe "xvfb"

if gentoo?
  portage_package_use "dev-lang/python" do
    use %w(sqlite)
  end

  portage_package_use "dev-libs/libxml2" do
    use %w(python)
  end

  portage_package_use "media-libs/libpng" do
    use %w(apng)
  end

  portage_package_use "x11-libs/pango" do
    use %w(X)
  end

  package "www-client/firefox"
elsif debian?
  package "iceweasel"
elsif ubuntu?
  package "firefox"
elsif mac?
  mac_package "Firefox" do
    source "http://download-installer.cdn.mozilla.net/pub/mozilla.org/firefox/releases/25.0/mac/en-US/Firefox%2025.0.dmg"
  end
end
