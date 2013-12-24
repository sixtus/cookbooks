include_recipe "mac"

# install base packages
node[:packages].each do |pkg|
  package pkg
end
