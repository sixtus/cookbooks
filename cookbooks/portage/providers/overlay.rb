use_inline_resources

action :create do
  nr = new_resource
  path = "/usr/local/portage/#{nr.name}"

  directory "/usr/local/portage" do
    owner "root"
    group "root"
    mode "0755"
  end

  git path do
    repository nr.repository
    notifies :create, "ruby_block[add-overlay-#{nr.name}]", :immediately
    notifies :create, "ruby_block[update-packages-cache]", :immediately
  end

  ruby_block "add-overlay-#{nr.name}" do
    block do
      node.set[:portage][:overlays][nr.name] = path
    end
    action :nothing
    notifies :create, "template[/etc/portage/make.conf]", :immediately
    notifies :create, "ruby_block[update-packages-cache]", :immediately
  end

  ruby_block "update-packages-cache" do
    action :nothing
    block do
      Chef::Provider::Package::Portage.new(nil, nil).packages_cache_from_eix!
    end
  end

  # copy due to use_inline_resources
  template "/etc/portage/make.conf" do
    owner "root"
    group "root"
    mode "0644"
    source "make.conf"
    cookbook "portage"
    backup 0
  end
end
