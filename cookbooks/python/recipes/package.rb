if gentoo?
  package "dev-lang/python"
elsif debian_based?
  package "python"
  package "python-dev"
elsif mac_os_x?
  package "python"
else
  raise "python cookbook does not support platform #{node[:platform]}"
end
