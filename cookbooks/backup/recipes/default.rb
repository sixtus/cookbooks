group "backup"
account_from_databag "backup"

ssh_chroot_sftp "backup" do
  directory "/backup"
end

node.run_state[:nodes].each do |n|
  next unless n[:backup] and n[:backup][:configs]

  directory "/backup/#{n[:fqdn]}" do
    owner "backup"
    group "backup"
    mode "0700"
  end
end
