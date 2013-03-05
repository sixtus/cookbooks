define :shorewall_lxc_bridge do
  # rebind in scope
  int, bridged = params[:interface], params[:bridged]

  shorewall_interface "lxc" do
    interface "#{int}:#{bridged}"
  end

  shorewall_zone "lxc:net" do
    type "bport"
  end

  shorewall_policy "lxc" do
    source "lxc"
    dest "all"
    policy "ACCEPT"
  end
end
