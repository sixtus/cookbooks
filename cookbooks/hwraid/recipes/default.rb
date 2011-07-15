devices = File.new("/proc/bus/pci/devices").readlines

if devices.grep(/aacraid/).any?
  include_recipe "hwraid::aac"
end
