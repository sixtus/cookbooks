include_recipe "python::pip"

if gentoo?
  package "dev-python/virtualenv"
elsif debian_based?
  package "python-virtualenv"
elsif mac_os_x?
  python_pip "virtualenv"
else
  raise "platform not supported"
end
