action :extract do
  r = new_resource
  basename = ::File.basename(r.name)
  local_archive = "#{r.download_dir}/#{basename}"

  remote_file basename do
    source r.name
    path local_archive
    backup false
    group r.group
    owner r.user
    mode "0644"
  end

  execute "extract #{basename}" do
    command "aunpack #{local_archive}"
    cwd r.target_dir
    creates r.creates
    group r.group
    user r.user
  end
end
