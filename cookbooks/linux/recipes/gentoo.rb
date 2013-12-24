if root?
  include_recipe "portage"

  # stupid #$%^&*
  link "/sbin/ip" do
    to "/bin/ip"
  end

  # move to netcat6
  package "net-analyzer/netcat" do
    action :remove
  end
end
