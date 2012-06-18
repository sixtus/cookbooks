define :shorewall_accounting,
  :target => "misc",
  :address => "-",
  :proto => "-",
  :port => "-" do

  node[:shorewall][:accounting][params[:name]] = params
end
