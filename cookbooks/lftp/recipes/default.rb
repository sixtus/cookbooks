package value_for_platform(
  "gentoo" => {"default" => "net-ftp/lftp"},
  "mac_os_x" => {"default" => "lftp"}
)

template node[:lftp][:configfile] do
  source "lftp.conf"
  owner "root"
  group "root"
  mode "0644"
end

unless platform?("mac_os_x")
  directory "/root/.lftp" do
    owner "root"
    group "root"
    mode "0700"
  end

  bookmarks = []

  node[:lftp][:bookmarks].each do |name, url|
    bookmarks << "#{name} #{url}"
  end

  file "/root/.lftp/bookmarks" do
    content bookmarks.join("\n")
    owner "root"
    group "root"
    mode "0600"
  end
end
