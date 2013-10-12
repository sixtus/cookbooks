if gentoo?
  package "dev-python/pip"
elsif debian_based?
  package "python-pip"
end
