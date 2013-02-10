nodes.all do |node|
  save = false

  [:default, :normal, :override].each do |level|
    method = (level.to_s + '_attrs').to_sym
    [:chef_environment].each do |key|
      if node.send(method).key?(key)
        puts "Removing #{level}[#{key}] from #{node[:fqdn]}"
        node.send(method).delete(key)
        save = true
      end
    end
  end

  node.save if save
end
