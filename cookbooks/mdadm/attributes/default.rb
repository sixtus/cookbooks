if FileTest.exists?("/proc/mdstat") and FileTest.exists?("/sbin/mdadm")
  default[:mdadm][:devices] = root? ? %x(/sbin/mdadm -Q --examine --brief /dev/sd*).split("\n") : []
end
