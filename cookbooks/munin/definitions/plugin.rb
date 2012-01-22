define :munin_plugin, :action => :create, :plugin => nil, :source => nil, :config => [] do
  next if not tagged?("munin-node")
  next if platform?("mac_os_x")
  next if solo?

  params[:plugin] = params[:name] unless params[:plugin]
  plugin_exec = "/usr/libexec/munin/plugins/#{params[:plugin]}"
  plugin_link = "/etc/munin/plugins/#{params[:name]}"
  plugin_conf = "/etc/munin/plugin-conf.d/#{params[:name]}.conf"

  if params[:source]
    cookbook_file plugin_exec do
      source params[:source]
      owner "root"
      group "root"
      mode "0755"
    end
  end

  if params[:action] == :create
    link plugin_link do
      to plugin_exec
      notifies :restart, "service[munin-node]"
    end

    unless params[:config].empty?
      content = "[#{params[:name]}]\n#{params[:config].join("\n")}\n"

      file plugin_conf do
        content content
        owner "root"
        group "root"
        mode "0640"
        notifies :restart, "service[munin-node]"
      end
    else
      file plugin_conf do
        action :delete
      end
    end
  else
    file plugin_link do
      action :delete
      notifies :restart, "service[munin-node]"
    end

    file plugin_conf do
      action :delete
      notifies :restart, "service[munin-node]"
    end
  end
end
