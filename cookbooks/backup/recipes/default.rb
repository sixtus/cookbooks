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
    home "/backup"
    home_owner "root"
    home_group "root"
    home_mode "0755"
  end

  group "backup" do
    members u[:id]
    append true
  end

  # special case for user backup:
  #
  # create directories for all hosts
  # that want to do backup via duply
  if u[:id] == "backup"
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
  elsif u[:backup_paths]
    u[:backup_paths].each do |p|
      directory "/backup/#{p}" do
        owner u[:id]
        group "backup"
        mode "0700"
      end
    end
  end

  u[:chroot] = true if u[:chroot].nil?

  if u[:chroot]
    ssh_chroot_sftp u[:id] do
      directory "/backup"
    end
  end
end
