execute "install homebrew" do
  command "curl -sfL #{node[:homebrew][:repo]}/tarball/master | tar zx -m --strip 1"
  cwd "/usr/local"
  creates "/usr/local/bin/brew"
end

package "git"

execute "set homebrew origin" do
  command "git remote set-url origin #{node[:homebrew][:repo]}"
  cwd "/usr/local/"
  only_if do
    %x(GIT_DIR=/usr/local/.git git remote show -n origin | grep Fetch | awk '{print $3}').chomp != node[:homebrew][:repo]
  end
end

execute "update homebrew from github" do
  command "/usr/local/bin/brew update || true"
  only_if do
    Time.now - File.stat("/usr/local/.git/index").mtime > 3600
  end
end
