if systemd_running?
  homedir = "/var/app/j2q"

  include_recipe "golang"

  deploy_skeleton "j2q"

  systemd_unit "j2q.service" do
    template "j2q.service"
    variables({
      path: homedir,
      user: "j2q",
      group: "j2q",
    })
    notifies :restart, "service[j2q]"
  end

  deploy_go_application "j2q" do
    repository "https://github.com/remerge/j2q"
    notifies :restart, "service[j2q]"
  end

  service "j2q" do
    action [:enable, :start]
  end
end
