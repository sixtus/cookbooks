if root?
  include_recipe "apt"

  %w(
    nf_conntrack
    nf_conntrack_ipv4
    nf_conntrack_ipv6
  ).each do |mod|
    execute "ubuntu-load-#{mod}" do
      command "/sbin/modprobe #{mod}"
    end
  end
end
