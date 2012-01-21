# initialize /etc with git to keep track of changes
include_recipe "git"

execute "git init" do
  cwd "/etc"
  creates "/etc/.git"
end

directory "/etc/.git" do
  owner "root"
  group "root"
  mode "0700"
end

file "/etc/.gitignore" do
  content <<-EOS
*~
adjtime
config-archive
hosts.deny*
ld.so.cache
mtab
resolv*
EOS
  owner "root"
  group "root"
  mode "0644"
end

bash "commit changes to /etc" do
  code <<-EOS
cd /etc
git add -A .
git commit -m 'automatic commit during chef-client run'
git gc
EOS
  not_if { %x(env GIT_DIR=/etc/.git GIT_WORK_TREE=/etc git status --porcelain).strip.empty? }
end
