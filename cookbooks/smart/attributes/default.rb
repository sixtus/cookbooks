default[:smart][:devices] = node[:block_device].select do |name, dev|
  dev[:vendor] == 'ATA' and
  dev[:model] not in [
    'VBOX HARDDISK',
  ]
end.map do |name, dev|
  "/dev/#{name}"
end
