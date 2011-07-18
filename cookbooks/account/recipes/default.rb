include_recipe "bash"

directory "/home" do
  owner "root"
  group "root"
  mode "0755"
end

# remove obsolete root dotfiles
%w(
  .bash_profile
  .bash
  .cvsrc
  .gitconfig
  .screenrc
  .tmux.conf
  .vimrc
).each do |f|
  file "/root/#{f}" do
    action :delete
    backup 0
  end
end

directory "/root/.vim" do
  action :delete
  recursive true
  only_if { File.symlink?("/root/.vim") }
end

execute "rm -f /root/.bashrc" do
  only_if { File.symlink?("/root/.bashrc") }
end

directory "/root/.dotfiles" do
  action :delete
  recursive true
end

query = Proc.new do |u|
  u[:tags] and u[:tags].include?("hostmaster")
end

accounts_from_databag "hostmasters" do
  groups %w(cron portage wheel)
  query query
end
