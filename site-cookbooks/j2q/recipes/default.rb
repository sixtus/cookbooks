if systemd_running?
  name = "j2q"
  homedir = "/var/app/#{name}"

  include_recipe "golang"

  deploy_skeleton name

  systemd_unit "#{name}.service" do
    template "#{name}.service"
    variables({
      name: name,
      homedir: homedir,
    })
    notifies :restart, "service[#{name}]"
  end

  deploy_go_artifact name do
    remote_path "/remerge/#{name}/#{node.chef_environment}/#{name}"
    bucket "remerge-artifacts"
    aws_access_key_id "AKIAJ63MRULNATSCEERA"
    aws_secret_access_key "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"
    notifies :restart, "service[#{name}]"
  end

  service name do
    action [:enable, :start]
  end
end
