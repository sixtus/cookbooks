define :shorewall_accounting,
  :target => "misc",
  :address => "-",
  :proto => "-",
  :port => "-" do

  node[:shorewall][:accounting][params[:name]] = params

  if tagged?("munin-node")
    munin_plugin "shorewall_accounting_#{params[:target]}" do
      plugin "shorewall_accounting"
      config ["user root"]
    end
  end
end
