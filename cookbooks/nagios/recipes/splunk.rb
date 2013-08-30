package "dev-ruby/nokogiri"

master = node.run_state[:"splunk-master"].first
search = node.run_state[:"splunk-search"].first

template "/usr/lib/nagios/plugins/check_splunk" do
  source "check_splunk.rb"
  owner "root"
  group "nagios"
  mode "0750"
  variables({
    master: master,
    search: search,
  })
end
