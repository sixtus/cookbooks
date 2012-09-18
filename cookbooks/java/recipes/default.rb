if platform?("gentoo")
  case node[:java][:vm]
  when /^icedtea-bin-/
    package "dev-java/icedtea-bin"
  end

  execute "ensure #{node[:java][:vm]} is the system vm" do
    command "eselect java-vm set system #{node[:java][:vm]}"
    not_if { %x(eselect --brief java-vm show system).strip == node[:java][:vm] }
  end
end
