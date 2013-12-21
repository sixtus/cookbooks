directory "/home" do
  owner "root"
  group "root"
  mode "0755"
end

hostmaster_groups = %w(adm cron)

if gentoo?
  hostmaster_groups += %w(portage wheel systemd-journal)
elsif debian?
  hostmaster_groups += %w(sudo)
end

# create accounts from databags
node.run_state[:users].select do |user|
  if user[:tags] && user[:tags].include?("hostmaster")
    true
  elsif user[:nodes] && user[:nodes][node[:fqdn]]
    true
  elsif user[:tags] && !(node[:account][:tags] & user[:tags]).empty?
    true
  else
    false
  end
end.each do |user|
  tags = [user[:tags]]
  tags += user[:nodes][node[:fqdn]].to_a if user[:nodes]
  tags.flatten!.compact!

  account_skeleton user[:id] do
    user.keys.each do |key, value|
      next if [:id, :name].include?(key.to_sym)
      send(key.to_sym, value) if value
    end
    groups hostmaster_groups if tags.include?("hostmaster")
  end
end
