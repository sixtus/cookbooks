include_recipe "python::pip"

if platform?("gentoo")
  package "dev-python/virtualenv"
else
  package "python-virtualenv"
end
