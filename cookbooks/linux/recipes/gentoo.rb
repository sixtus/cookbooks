include_recipe "portage"

# stupid #$%^&*
link "/sbin/ip" do
  to "/bin/ip"
end
