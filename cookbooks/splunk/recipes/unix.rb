git "/opt/splunk/etc/apps/Splunk_TA_nix" do
  repository "https://github.com/zenops/splunk-Unix-TA"
  reference "master"
  action :sync
  notifies :restart, "service[splunk]" if splunk_forwarder?
end

if node.role?("splunk-search") or node.role?("splunk-server")
  git "/opt/splunk/etc/apps/SA-nix" do
    repository "https://github.com/zenops/splunk-Unix-SA"
    reference "master"
    action :sync
  end

  git "/opt/splunk/etc/apps/splunk_app_for_nix" do
    repository "https://github.com/zenops/splunk-Unix"
    reference "master"
    action :sync
  end
end
