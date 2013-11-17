if gentoo?
  package "app-portage/overlint"
end

shorewall_rule "workstation" do
  destport "3000:3099"
end
