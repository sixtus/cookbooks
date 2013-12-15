if gentoo?
  portage_package_use "sys-libs/zlib" do
    use %w(minizip)
  end

  portage_package_use "dev-lang/R" do
    use %w(cairo)
  end

  package "dev-lang/R"
elsif mac_os_x?
  package "r"
else
  raise "platform not supported"
end
