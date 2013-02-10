nodes.all do |node|
  [:default, :normal, :override].each do |level|
    a = node.send((level.to_s + '_attrs').to_sym)
    a[:tags].delete("munin-node") rescue nil
    a[:nagios][:services].delete("MUNIN-NODE") rescue nil
    a.delete(:munin) rescue nil
  end

  node.save
end
