bash "install homebrew" do
  code "curl -fsSL https://raw.github.com/mxcl/homebrew/go | ruby"
  not_if { File.exist?("/usr/local/bin/brew") }
end

execute "set homebrew origin" do
  command "git remote set-url origin #{node[:homebrew][:repo]}"
  cwd "/usr/local/"
  only_if do
    File.exist?("/usr/local/.git") and
    %x(GIT_DIR=/usr/local/.git git remote show -n origin | grep Fetch | awk '{print $3}').chomp != node[:homebrew][:repo]
  end
end

git "/usr/local" do
  repository node[:homebrew][:repo]
  reference "master"
  action :checkout
end
