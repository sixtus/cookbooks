use_inline_resources

action :create do
  execute "layman -f -a #{new_resource.name}" do
    creates "/var/lib/layman/#{new_resource.name}"
    notifies :create, "ruby_block[update-packages-cache]", :immediately
  end
end

action :delete do
  execute "layman -d #{new_resource.name}" do
    only_if { File.directory?("/var/lib/layman/#{new_resource.name}") }
    notifies :create, "ruby_block[update-packages-cache]", :immediately
  end
end
