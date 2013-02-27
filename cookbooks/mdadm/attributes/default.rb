if FileTest.exists?("/proc/mdstat") and FileTest.exists?("/sbin/mdadm")
  default[:mdadm][:devices] = root? ? %x(/sbin/mdadm -Q --examine --brief /dev/disk/by-id/*-part*).split("\n") : []
end
