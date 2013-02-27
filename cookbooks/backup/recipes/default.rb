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
    home_mode "0711"
  end

  group "backup-#{rrand}" do
    group_name "backup"
    members u[:id]
    append true
  end

  if u[:chroot] or u[:chroot].nil?
    ssh_chroot_sftp u[:id] do
      directory "/backup"
    end
  end

  # special case for user backup:
  #
  # create directories for all hosts that want to do backup via duply since
  # duplicity does not create directories recusrively ... *sigh*
  #
  if u[:id] == "backup"
    node.run_state[:nodes].each do |n|
      next unless n[:backup]
      next unless n[:backup][:configs]
      next if n[:backup][:configs].empty?

      directory "/backup/backup/#{n[:fqdn]}" do
        owner "backup"
        group "backup"
        mode "0700"
      end
    end
  end
end
