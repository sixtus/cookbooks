if node[:virtualization][:role] == "guest"
  default[:openrc][:sys] = case node[:virtualization][:system]
                             when "linux-vserver"
                               "vserver"
                             else
                               raise "Unsupported virtualization system: #{node[:virtualization][:system]}"
                             end
else
  default[:openrc][:sys] = ""
end
