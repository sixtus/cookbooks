if platform?("gentoo")
  package "dev-java/sun-jdk"

  execute "ensure java 1.6 is the system vm" do
    command "eselect java-vm set system sun-jdk-1.6"
    not_if { %x(eselect --brief java-vm show system).strip == "sun-jdk-1.6" }
  end
end
