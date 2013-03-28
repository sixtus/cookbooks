# monkeypatch data_bag_item for better DSL
class Chef::DataBagItem
  def method_missing(sym, *args, &block)
    self.raw_data.store(sym, *args, &block)
  end
end

def generate_metadata
  knife :cookbook_metadata, ['--all']
end

def cookbook_metadata
  files = [
    Dir[File.join(COOKBOOKS_DIR, "*/metadata.json")],
    Dir[File.join(SITE_COOKBOOKS_DIR, "*/metadata.json")],
  ].flatten.sort_by do |filename|
    File.dirname(filename)
  end

  files.select! do |file|
    File.exist?(File.join(File.dirname(file), 'metadata.rb'))
  end

  files.map do |file|
    cookbook = File.basename(File.dirname(file))
    metadata = parse_json(File.read(file)).symbolize_keys
    metadata[:path] = File.dirname(file)
    [cookbook, metadata]
  end
end

def search(default_query)
  ENV['QUERY'] = default_query if not ENV.key?('QUERY')
  nodes = Chef::Search::Query.new.search(:node, ENV['QUERY']).first.compact
  nodes.sort_by { |n| n[:fqdn] }.each do |node|
    next if node[:skip] and node[:skip][:rc] # TODO: does not belong here
    puts(">>> #{node.name}")
    yield node
  end
end

# overwrite knife from knife-dsl
class << eval("self", TOPLEVEL_BINDING)
  def knife(command, args)
    stdout, stderr, status = knife_capture(command, args)

    if status != 0
      puts stderr
      raise "knife #{command} #{args.join(' ')} failed"
    end

    [stdout, stderr, status]
  end
end
