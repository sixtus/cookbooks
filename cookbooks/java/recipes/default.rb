if platform?("gentoo")
  case node[:java][:vm]
  when /^icedtea-bin-/
    portage_package_use "x11-libs/cairo" do
      use %w(X)
    end

    portage_package_use "x11-libs/gdk-pixbuf" do
      use %w(X)
    end

    package "dev-java/icedtea-bin" do
      action :upgrade
    end
  else
    raise "unsupported JVM: #{node[:java][:vm]}"
  end

  execute "ensure #{node[:java][:vm]} is the system vm" do
    command "eselect java-vm set system #{node[:java][:vm]}"
    not_if { %x(eselect --brief java-vm show system).strip == node[:java][:vm] }
  end
end
