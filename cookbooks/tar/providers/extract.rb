use_inline_resources

action :extract do
  r = new_resource
  basename = ::File.basename(r.source)
  local_archive = "#{r.download_dir}/#{basename}"

  remote_file basename do
    source r.source
    path local_archive
    backup false
    group r.group
    owner r.user
    mode "0644"
  end

  execute "extract #{basename}" do
    command "tar xvf #{local_archive} -C #{r.target_dir} --keep-directory-symlink --owner=#{r.user} --group=#{r.group}"
    creates r.creates
    group r.group
    user r.user
  end
end
