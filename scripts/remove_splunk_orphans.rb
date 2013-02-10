nodes.all do |node|
  [:default, :normal, :override].each do |level|
    a = node.send((level.to_s + '_attrs').to_sym)
    a[:splunk][:inputs].delete("monitor:///var/log/nginx/access_log") rescue nil
    a[:splunk][:inputs].delete("monitor:///var/log/chef/client.log") rescue nil
  end

  node.save
end
