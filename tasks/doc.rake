require "terminal-table/import"

def node_documentation(node)
  erb = Erubis::Eruby.new(File.read(File.join(DOC_SOURCE_DIR, "local", "nodes", "node.rst.erb")))
  open(File.join(DOC_SOURCE_DIR, "local", "nodes", "#{node[:fqdn]}.rst"), "w") do |f|
    f.puts erb.result(:node => node)
  end
end

namespace :doc do

  desc "Upload and deploy documentation"
  task :deploy => [ :generate ]
  task :deploy do
    system("knife cookbook upload chef")
    Chef::Search::Query.new.search(:node, "role:chef") do |n|
      system("ssh -t #{n[:fqdn]} '/usr/bin/sudo -H /usr/bin/chef-client'")
    end
  end

  desc "Generate all documentation sources"
  task :generate => [ :contacts, :nodes ]
  task :generate do
    system("rm -rf #{TOPDIR}/cookbooks/chef/files/default/documentation/html/*")
    system("make -C #{TOPDIR}/documentation html")
  end

  desc "Generate contacts"
  task :contacts do
    contacts = table do |tbl|
      # heading
      tbl << [
        "**Name**",
        "**E-Mail**",
        "**Mobile Phone**",
        "**Role**"
      ]

      Chef::Search::Query.new.search(:users, "role:[* TO *]")[0].each do |u|
        tbl.add_separator
        tbl << [
          u[:comment],
          u[:email],
          u[:pager],
          u[:role],
        ]
      end
    end

    ert = table do |tbl|
      tbl << [
        "**Weekday**",
        "**Office Hours**",
        "**Non-office Hours**",
      ]

      oc = {}

      Chef::Search::Query.new.search(:users, "on_call:[* TO *]")[0].each do |u|
        u[:on_call].each do |wday, periods|
          wday = wday.to_sym

          oc[wday] ||= {}
          oc[wday][:day] ||= []
          oc[wday][:night] ||= []

          if periods.include?("daytime")
            oc[wday][:day] |= [u[:comment]]
          end

          if periods.include?("nighttime")
            oc[wday][:night] |= [u[:comment]]
          end
        end
      end

      long = {
        :mon => "Monday",
        :tue => "Tuesday",
        :wed => "Wednesday",
        :thu => "Thursday",
        :fri => "Friday",
        :sat => "Saturday",
        :sun => "Sunday"
      }

      [:mon, :tue, :wed, :thu, :fri, :sat, :sun].each do |wday|
        oc[wday] ||= {}
        oc[wday][:day] ||= []
        oc[wday][:night] ||= []

        tbl.add_separator
        tbl << [
          long[wday],
          oc[wday][:day].join(","),
          oc[wday][:night].join(","),
        ]
      end
    end

    tp = Chef::Search::Query.new.search(:config, "id:timeperiods")[0][0]

    erb = Erubis::Eruby.new(File.read(File.join(DOC_SOURCE_DIR, "local", "overview.rst.erb")))
    open(File.join(DOC_SOURCE_DIR, "local", "overview.rst"), "w") do |f|
      f.puts erb.result({
        :contacts => contacts,
        :ert => ert,
        :tp => tp,
      })
    end
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

task :doc => "doc:deploy"
