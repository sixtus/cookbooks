unless platform?("mac_os_x")
  package "app-editors/vim"
end

cookbook_file node[:vim][:rcfile] do
  source "vimrc"
  mode "0644"
end

cookbook_file "/usr/local/bin/mvim" do
  source "mvim"
  mode "0755"
end
