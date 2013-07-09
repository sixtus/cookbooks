action :extract do
  r = new_resource
  basename = ::File.basename(r.name)
  local_archive = "#{r.download_dir}/#{basename}"

  remote_file basename do
    source r.name
    path local_archive
    backup false
    action :nothing
    group r.group
    owner r.user
    mode r.mode
  end

  http_request "HEAD #{r.name}" do
    message ""
    url r.name
    action :head
    if ::File.exists?(local_archive)
      headers "If-Modified-Since" => ::File.mtime(local_archive).httpdate
    end
    notifies :create, "remote_file[#{basename}]", :immediately
  end

  execute "extract #{basename}" do
    command "aunpack #{local_archive}"
    cwd r.target_dir
    creates r.creates
    group r.group
    user r.user
  end
end
