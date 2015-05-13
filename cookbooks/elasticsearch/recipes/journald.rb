if systemd_running? && elasticsearch_nodes(node[:elasticsearch][:journald][:cluster]).length > 0
  homedir = "/var/app/elastic-journald"

  include_recipe "golang"

  deploy_skeleton "elastic-journald"

  systemd_unit "elastic-journald.service" do
    template "elastic-journald.service"
    variables({
      path: homedir,
      user: "elastic-journald",
      group: "elastic-journald",
    })
  end

  deploy_go_application "elastic-journald" do
    repository node[:elasticsearch][:journald][:git]
    revision node[:elasticsearch][:journald][:revision]
    notifies :restart, "service[elastic-journald]"
  end

  service "elastic-journald" do
     action [:enable, :start]
  end
elsif systemd_running?
  service "elastic-journald" do
     action [:disable, :stop]
  end  
end
