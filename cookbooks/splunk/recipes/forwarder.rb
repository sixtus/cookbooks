unless node.recipe?("splunk::indexer") or node.role?("logger")
  tag("splunk-forwarder")

  package "net-analyzer/splunkforwarder"

  include_recipe "splunk"

  indexer_nodes = node.run_state[:nodes].select do |n|
    n[:tags].include?("splunk-indexer") rescue false
  end

  template "/opt/splunk/etc/system/local/outputs.conf" do
    source "outputs.conf"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[splunk]"
    variables :indexer_nodes => indexer_nodes
  end
end
