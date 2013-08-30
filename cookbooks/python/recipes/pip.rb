case node[:platform]
when "gentoo"
  package "dev-python/pip"
when "debian"
  package "python-setuptools"
  easy_install_package "pip"
end
