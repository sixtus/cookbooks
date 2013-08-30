forwarder = [
  node.role?("splunk-master"),
  node.role?("splunk-peer"),
  node.role?("splunk-search"),
  node.role?("splunk-server"),
].none?

if forwarder
  case node[:platform]
  when "gentoo"
    package "net-analyzer/splunkforwarder"

  when "debian"
    remote_file "/tmp/splunkforwarder-5.0.2-149561-linux-2.6-amd64.deb" do
      source "http://www.splunk.com/page/download_track?file=5.0.2/universalforwarder/linux/splunkforwarder-5.0.2-149561-linux-2.6-amd64.deb&ac=get_splunk_download&wget=true&name=wget&typed=releases"
      mode "0644"
      checksum "e4a16af9764880c2784abad6b2b77e86c65b684a0c24dfbbcf60078e3f152feb"
    end

    dpkg_package "splunkforwarder" do
      source "/tmp/splunkforwarder-5.0.2-149561-linux-2.6-amd64.deb"
      action :install
    end

    link "/opt/splunk" do
      to "/opt/splunkforwarder"
    end
  end

  include_recipe "splunk::common"
end
