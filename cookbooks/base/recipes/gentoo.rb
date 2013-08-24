if root?
  include_recipe "portage"
  include_recipe "portage::porticron"

  # cleanup old mess
  %w(
    dev-ruby-haml
  ).each do |f|
    file "/etc/portage/package.keywords/chef-#{f}" do
      action :delete
    end
  end

  %w(
    dev-lang-python-3
    dev-lang-ruby-2
  ).each do |f|
    file "/etc/portage/package.mask/chef-#{f}" do
      action :delete
    end
  end

  %w(
    sys-fs-lvm2
    sys-fs-mdadm
    sys-fs-udev
    virtual-udev
    sys-apps-openrc
  ).each do |f|
    file "/etc/portage/package.use/chef-#{f}" do
      action :delete
    end
  end

  # stupid #$%^&*
  link "/sbin/ip" do
    to "/bin/ip"
  end

  # move to netcat6
  package "net-analyzer/netcat" do
    action :remove
  end
end
