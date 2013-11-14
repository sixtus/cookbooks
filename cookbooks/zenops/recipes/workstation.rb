package "app-portage/gentoolkit"
package "app-portage/gentoolkit-dev"
package "app-portage/overlint"

shorewall_rule "workstation" do
  destport "3000:3099"
end
