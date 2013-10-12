python_pkgs = value_for_platform_family(
  "gentoo" => ["dev-lang/python"],
  "debian" => ["python","python-dev"],
  "ubuntu" => ["python","python-dev"],
  "mac_os_x" => ["python"]
)

python_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end
