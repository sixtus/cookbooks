default[:smart][:devices] = (node[:block_device] or {}).select do |name, dev|
  dev[:vendor] == 'ATA'
end.reject do |name, dev|
  [
    'VBOX HARDDISK',
  ].include?(dev[:model])
end.map do |name, dev|
  "/dev/#{name}"
end
