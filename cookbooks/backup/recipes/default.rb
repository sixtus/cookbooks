group "backup"
account_from_databag "backup"

ssh_chroot_sftp "backup" do
  directory "/backup"
end

node.run_state[:nodes].each do |n|
  next unless n[:backup]
  next unless n[:backup][:configs]
  next if n[:backup][:configs].empty?

  directory "/backup/#{n[:fqdn]}" do
    owner "backup"
    group "backup"
    mode "0700"
  end
end
