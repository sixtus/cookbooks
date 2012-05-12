portage_package_use "x11-base/xorg-server" do
  use %w(-xorg minimal xvfb)
end

portage_package_use "x11-apps/xinit" do
  use %w(minimal)
end

package "x11-base/xorg-server"
