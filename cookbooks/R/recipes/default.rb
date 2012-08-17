portage_package_use "sys-libs/zlib" do
  use %w(minizip)
end

portage_package_use "x11-libs/cairo" do
  use %w(X)
end

portage_package_use "dev-lang/R" do
  use %w(cairo)
end

package "dev-lang/R"
