execute "set homebrew origin" do
  command "git remote set-url origin #{node[:homebrew][:repo]}"
  cwd "/usr/local/"
  only_if do
    %x(GIT_DIR=/usr/local/.git git remote show -n origin | grep Fetch | awk '{print $3}').chomp != node[:homebrew][:repo]
  end
end

git "/usr/local" do
  repository node[:homebrew][:repo]
  reference "master"
  action :sync
end
