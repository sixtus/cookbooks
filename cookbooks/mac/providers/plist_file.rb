def whyrun_supported?
  true
end

use_inline_resources

action :create do
  file "#{node[:homedir]}/Library/Preferences/#{new_resource.source}.lockfile" do
    action :delete
  end

  cookbook_file "#{node[:homedir]}/Library/Preferences/#{new_resource.source}" do
    source new_resource.source
    cookbook new_resource.cookbook unless new_resource.cookbook.empty?
    ignore_failure true
  end
end
