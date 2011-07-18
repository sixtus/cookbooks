directory "/backup" do
  owner "root"
  group "root"
  mode "0755"
end

node.run_state[:users].select do |u|
  u[:tags] and u[:tags].include?("backup")
end.each do |u|
  account_from_databag u[:id] do
    gid "backup"
    home "/backup/#{u[:id]}"
    home_owner u[:id]
    home_group "backup"
    home_mode "0700"
  end

  group "backup" do
    members u[:id]
    append true
  end

  u[:chroot] = true if u[:chroot].nil?

  if u[:chroot]
    ssh_chroot_sftp u[:id] do
      directory "/backup"
    end
  end
end
