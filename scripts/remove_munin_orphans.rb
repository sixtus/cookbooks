nodes.all do |node|
  [:default, :normal, :override].each do |level|
    a = node.send((level.to_s + '_attrs').to_sym)
    a[:tags].delete("munin-node") rescue puts "failed to delete tag on #{node[:fqdn]}"
    a[:nagios][:services].delete("MUNIN-NODE") rescue puts "failed to delete nagios service on #{node[:fqdn]}"
    a.delete(:munin) rescue puts "failed to delete munin attributes from #{node[:fqdn]}"
  end

  node.save
end
