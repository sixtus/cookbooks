include_recipe "ssh"

execute "gitolite-install" do
  command "/usr/local/src/gitolite/install -ln /usr/local/bin"
  action :nothing
end

directory "/usr/local/src" do
  owner "root"
  group "root"
  mode "0755"
end

git "/usr/local/src/gitolite" do
  repository "https://github.com/sitaramc/gitolite"
  reference "51833fccfbe7fa7736f2ab2494b452cd23decf5e"
  action :sync
  notifies :run, "execute[gitolite-install]"
end

group "git" do
  gid 202
  append true
end

user "git" do
  uid 104
  gid 202
  home "/var/lib/gitolite"
  shell "/bin/bash"
  comment "gitolite"
end

directory "/var/lib/gitolite" do
  owner "git"
  group "git"
  mode "0750"
end

execute "gitolite-key" do
  command "cp /root/.ssh/id_rsa.pub /var/lib/gitolite/root.pub"
  creates "/var/lib/gitolite/root.pub"
end

template "/var/lib/gitolite/.gitolite.rc" do
  source "gitolite.rc"
  owner "git"
  group "git"
  mode "0644"
  notifies :run, "execute[gitolite-setup]"
end

execute "gitolite-setup-initial" do
  command "/usr/local/bin/gitolite setup -pk /var/lib/gitolite/root.pub"
  creates "/var/lib/gitolite/repositories/gitolite-admin.git"
  environment ({'HOME' => "/var/lib/gitolite"})
  user "git"
  group "git"
end

execute "gitolite-setup" do
  command "/usr/local/bin/gitolite setup"
  environment ({'HOME' => "/var/lib/gitolite"})
  user "git"
  group "git"
  action :nothing
end

%w(
  pre-receive
  post-receive
).each do |hook|
  cookbook_file "/var/lib/gitolite/.gitolite/hooks/common/#{hook}" do
    source "hooks/#{hook}"
    owner "git"
    group "git"
    mode "0755"
    notifies :run, "execute[gitolite-setup]"
  end
end
