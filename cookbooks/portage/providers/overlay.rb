use_inline_resources

action :create do
  nr = new_resource
  path = "/var/lib/portage/#{nr.name}"

  file "#{node[:portage][:confdir]}/repos.conf/#{nr.name}.conf" do
    content "[#{nr.name}]\nlocation = #{path}\nsync-type = git\nsync-uri = #{nr.repository}\nauto-sync = yes\n"
    owner "root"
    group "root"
    mode "0644"
    notifies :run, "ruby_block[add-overlay-#{nr.name}]", :immediately
  end

  ruby_block "add-overlay-#{nr.name}" do
    block do
      node.set[:portage][:overlays][nr.name] = path
    end
    only_if { node[:portage][:overlays][nr.name].nil? }
    notifies :run, "execute[update-overlay-#{nr.name}]", :immediately
    notifies :create, "ruby_block[update-packages-cache]", :immediately
    notifies :create, "file[/etc/portage/make.profile/parent]", :immediately
  end

  execute "update-overlay-#{nr.name}" do
    command "emaint sync -r #{nr.name}"
    action :nothing
  end

  # copy due to use_inline_resources
  file "/etc/portage/make.profile/parent" do
    content "#{node[:portage][:profile]}\n#{node[:portage][:overlays].map { |name, _path| "#{_path}/profiles/#{name}" }.select { |x| ::File.exist?(x) }.join("\n")}"
    owner "root"
    group "root"
    mode "0644"
  end

  ruby_block "update-packages-cache" do
    action :nothing
    block do
      Chef::Provider::Package::Portage.new(nil, nil).packages_cache_from_eix!
    end
  end
end
