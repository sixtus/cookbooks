if root?
  include_recipe "portage"
  include_recipe "portage::porticron"

  # basic keywords & use flags
  portage_package_keywords "dev-ruby/haml"
  portage_package_mask ">=dev-lang/python-3"

  portage_package_use "sys-fs/udev" do
    use %w(static-libs)
  end

  portage_package_use "virtual/udev" do
    use %w(static-libs)
  end

  portage_package_use "sys-fs/lvm2" do
    use %w(static static-libs)
  end

  # stupid #$%^&*
  link "/sbin/ip" do
    to "/bin/ip"
  end
end
