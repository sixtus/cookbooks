nodes.all do |node|
  [:default, :normal, :override].each do |level|
    a = node.send((level.to_s + '_attrs').to_sym)
    a[:splunk][:inputs].delete("monitor:///var/log/nginx/access_log") rescue puts "failed to delete splunk input on #{node[:fqdn]}"
  end

  node.save
end
