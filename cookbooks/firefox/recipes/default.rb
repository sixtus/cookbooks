include_recipe "xvfb"

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

portage_package_keywords "www-client/firefox"

package "www-client/firefox"
