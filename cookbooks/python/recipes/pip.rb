case node[:platform]
when "gentoo"
  package "dev-python/pip"
when "debian", "ubuntu"
  package "python-pip"
end
