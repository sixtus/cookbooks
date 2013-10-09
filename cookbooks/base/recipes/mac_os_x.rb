raise "running as root is not supported on mac os" if root?

include_recipe "mac"
include_recipe "homebrew"

# need to upgrade this one as early as possible or dircolors will break
package "xz"
package "coreutils" do
  action :upgrade
end

# install base packages
node[:packages].each do |pkg|
  package pkg
end

include_recipe "mac::iterm"
include_recipe "mac::alfred2"
include_recipe "mac::chrome"
