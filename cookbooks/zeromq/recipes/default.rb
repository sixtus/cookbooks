package value_for_platform({
  "gentoo" => {"default" => "net-libs/zeromq"},
  "mac_os_x" => {"default" => "zeromq"},
})

if node[:tags].include?("java")
  package "dev-java/jzmq" if platform?("gentoo")
end
