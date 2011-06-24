require "terminal-table/import"

def node_documentation(node)
  erb = Erubis::Eruby.new(File.read(File.join(DOC_SOURCE_DIR, "local", "nodes", "node.rst.erb")))
  open(File.join(DOC_SOURCE_DIR, "local", "nodes", "#{node[:fqdn]}.rst"), "w") do |f|
    f.puts erb.result(:node => node)
  end
end

namespace :doc do

  desc "Generate all documentation sources"
  task :all => [ :nodes ]
  task :all do
    sh("rm -rf #{TOPDIR}/cookbooks/chef/files/default/documentation/html/*")
    sh("make -C #{TOPDIR}/documentation html")
  end

  desc "Generate Node List"
  task :nodes do
    t = table do |t|
      # heading
      t << [
        "**Hostname**",
        "**Public IP address**",
        "**Local IP address**",
        "**Classification**"
      ]

      # list host nodes grouped by cluster first
      Chef::Search::Query.new.search(:node, "virtualization_role:host")[0].group_by do |n|
        n[:cluster][:name] or "default"
      end.sort_by do |cluster, nodes|
        cluster
      end.each do |cluster, nodes|
        t.add_separator
        t << [{:value => "**Cluster: #{cluster}**", :colspan => 4}]

        nodes.sort_by do |n|
          n[:fqdn]
        end.each do |n|
          t.add_separator
          t << [
            ":ref:`#{n[:fqdn]} <local-node-#{n[:fqdn]}>`",
            n[:ipaddress],
            (n[:local_ipaddress] or "--"),
            (n[:classification] or "non-critical")
          ]

          node_documentation(n)

          # TODO: add child count attribute to host node so we can speed this one up
          Chef::Search::Query.new.search(:node, "virtualization_host:#{n[:fqdn]}") do |cn|
            t.add_separator
            t << [
              "-- :ref:`#{cn[:fqdn]} <local-node-#{cn[:fqdn]}>`",
              cn[:ipaddress],
              (cn[:local_ipaddress] or "--"),
              (cn[:classification] or "non-critical")
            ]

            node_documentation(cn)
          end
        end
      end
    end

    erb = Erubis::Eruby.new(File.read(File.join(DOC_SOURCE_DIR, "local", "nodes", "index.rst.erb")))
    open(File.join(DOC_SOURCE_DIR, "local", "nodes", "index.rst"), "w") do |f|
      f.puts erb.result(:table => t)
    end
  end

end
