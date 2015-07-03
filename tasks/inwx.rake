require 'set'

begin
  namespace :inwx do
    def create_record(domain, entry, content)
      create_request = {
        domain: domain,
        type: entry[:type],
        content: content,
        name: entry[:name],
        prio: entry[:priority] || 0,
      }
      create_result = domrobot.call("nameserver", "createRecord", create_request)

      puts "Added #{create_request}\nresult #{create_result}"
    end

    def update_record(record, type, priority, content)
      update_request = {
        id: record['id'],
        type: type,
        content: content,
        name: record['name'],
        prio: priority,
      }
      update_result = domrobot.call("nameserver", "updateRecord", update_request)

      puts "Updated #{entry}\n#{update_result}"
    end

    def delete_record(record)
      delete_result = domrobot.call("nameserver", "deleteRecord", {
        id: record['id']
      })

      puts "Removed #{record}\n#{delete_result}"
    end

    def ensure_dns(domain, entry, must_match = false)
      query = {
        domain: domain,
        type: entry[:type],
      }
      if entry[:type] == "A" || entry[:type] == "AAAA" || entry[:type] == "CNAME"
        query[:name] = entry[:name] == "" ? domain : entry[:name]
      else
        query[:content] = entry[:content]
      end

      query_result = domrobot.call("nameserver", "info", query)

      if query_result['code'] != 1000
        puts "Ignoring #{entry.to_yaml}, because of #{query_result.to_yaml}"
        return
      end

      record = query_result['resData']['record']

      if record == nil && !entry[:delete]
        [entry[:content]].flatten.each do |content|
          create_record(domain, entry, content)
        end
      elsif entry[:delete]
        record.each do |r|
          delete_record(r)
        end
      else
        current = Hash.new
        record.each do |r|
          current[r['content']] = r
        end

        [entry[:content]].flatten.each do |wanted|
          match = current[wanted]
          if match == nil
            if record.length != 0 && must_match
              raise "INWX records do not match for #{entry}"
            end
            create_record(domain, entry, wanted)
          elsif match['type'] != entry[:type]
            match['prio'] != (entry[:priority] || 0)
            update_record(match, entry[:type], entry[:priority] || 0, wanted)
          end
          current.delete(wanted)
        end

        current.each do |unwanted, unwanted_record|
          delete_record(unwanted_record)
        end
      end
    end

    desc "list domains"
    task :domains do |t|
      domrobot.call("domain", "list")['resData']['domain'].each do |entry|
        puts "#{entry['domain']} - #{entry['status']} - #{entry['ns']}"
      end
    end

    desc "register static dns entries"
    task :static_dns do |t|
      domrobot.login($conf.inwx.user,$conf.inwx.token)
      $conf.inwx.domains.each do |domain, entries|
        puts "Checking DNS master for #{domain}"
        dns_check = domrobot.call("nameserver", "check", {
          domain: domain,
          ns: %w(ns.inwx.de ns2.inwx.de ns3.inwx.eu ns4.inwx.com ns5.inwx.net),
        })['resData']
        if dns_check['status'] == "OK"
          puts "OK"
        else
          "Ensuring domain #{domain} is served by inwx"
          puts domrobot.call("nameserver", "delete", {
            domain: domain,
          }).to_yaml
          puts domrobot.call("nameserver", "create", {
            domain: "#{domain}",
            type: 'MASTER',
            ns: %w(ns.inwx.de ns2.inwx.de ns3.inwx.eu ns4.inwx.com ns5.inwx.net),
          }).to_yaml
        end

        entries.each do |entry|
          ensure_dns(domain, entry)
        end
      end
    end

    desc "register hosts"
    task :register_hosts do |t|
      $conf.inwx.domains.each do |domain, entries|
        puts "checking #{domain}"
        stdout, stderr, status = knife_capture :search_node, ["fqdn:*.#{domain}", "-F", "json"]
        fail if status > 0
        nodes = JSON.parse(stdout)['rows'].map do |node|
          {
            fqdn: node['automatic']['fqdn'],
            ipaddress: node['automatic']['ipaddress'],
            ip6address: node['automatic']['ip6address'],
          }
        end

        nodes.each do |node|
          ensure_dns(domain, {
            type: "A",
            name: node[:fqdn],
            content: node[:ipaddress],
          })
          # if entry[:ip6address]
          #   ensure_dns(domain, {
          #     type: "AAAA",
          #     name: node[:fqdn],
          #     content: node[:ip6address],
          #   })
          # end
        end
        puts "done with #{domain}, #{nodes.length} entries"
      end
    end
  end
rescue LoadError
  $stderr.puts "INWX API cannot be loaded. Skipping some rake tasks ..."
end
