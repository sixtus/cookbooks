require 'chef/node'
require 'chef/data_bag'
require 'chef/data_bag_item'

desc "Pull changes from the remote repository"
task :pull do
  unless ENV.include?('BOOTSTRAP')
    sh("git checkout -q master")
    sh("git pull -q")
  end
end

namespace :load do

  desc "Upload all entities"
  task :all => [ :cookbooks, :nodes, :roles, :environments, :databags ]

  desc "Upload all cookbooks"
  task :cookbooks => [ 'generate:metadata' ]
  task :cookbooks do
    puts ">>> Uploading cookbooks"
    cookbook_metadata.each do |cookbook, metadata|
      platforms = metadata[:platforms].keys - CHEF_SOLO_PLATFORMS
      version = metadata[:version]

      if platforms.empty?
        printf "  - %-20.20s [%s] (it only supports chef-solo platforms)\n", cookbook, version
        next
      end

      if version == "0.0.0"
        printf "  + %-20.20s [%s]\n", cookbook, version
        knife :cookbook_upload, [cookbook]
        next
      end

      stdout, _, status = knife_capture :cookbook_show, [cookbook, version, '-F', 'json']

      # version does not exist
      if status != 0
        printf "  + %-20.20s [%s]\n", cookbook, version
        knife :cookbook_upload, [cookbook, '--freeze']
        next
      end

      cb = parse_json(stdout)

      # new version or not yet frozen
      if version != cb[:version] or not cb[:frozen?]
        printf "  + %-20.20s [%s]\n", cookbook, version
        knife :cookbook_upload, [cookbook, '--freeze']
        next
      end

      # forced cookbooks
      if FORCED_COOKBOOKS.include?(cookbook)
        printf "  + %-20.20s [%s] (forced)\n", cookbook, version
        knife :cookbook_upload, [cookbook, '--force', '--freeze']
        next
      end

      # check for missing version bumps
      files = %w(
        recipes
        definitions
        libraries
        attributes
        files
        templates
        resources
        providers
        root_files
      ).map do |type|
        cb[type.to_sym].map(&:with_indifferent_access)
      end.flatten

      files.each do |file|
        # ignore overridable user templates
        next if file[:path] =~ %r{^templates/default/user-}

        path = File.join(metadata[:path], file[:path])
        checksum = Digest::MD5.hexdigest(File.read(path))

        if checksum != file[:checksum]
          raise "missing version bump for changes in #{path}"
        end
      end

      printf "  - %-20.20s [%s] (it has already been frozen)\n", cookbook, version
    end
  end

  desc "Upload a single node definition"
  task :node, :fqdn do |t, args|
    fqdn = args.fqdn

    begin
      n = Chef::Node.load(fqdn)
    rescue
      n = Chef::Node.new
      n.name(fqdn)
    end

    n.from_file(File.join(NODES_DIR, "#{fqdn}.rb"))

    printf "  + %-20.20s [%s]\n", n.name, n.chef_environment
    n.save
  end

  desc "Upload all node definitions"
  task :nodes do
    puts ">>> Uploading nodes"

    nodes = Dir[ File.join(NODES_DIR, '*.rb') ].map do |f|
      File.basename(f, '.rb')
    end.sort!

    nodes.each do |node|
      args = Rake::TaskArguments.new([:fqdn], [node])
      Rake::Task['load:node'].execute(args)
    end
  end

  desc "Upload a single role definition"
  task :role, :name do |t, args|
    name = args.name

    r = Chef::Role.new
    r.name(name)
    r.from_file(File.join(ROLES_DIR, "#{name}.rb"))

    printf "  + %-20s\n", r.name
    r.save
  end

  desc "Upload all role definitions"
  task :roles do
    puts ">>> Uploading roles"

    roles = Dir[ File.join(ROLES_DIR, '*.rb') ].map do |f|
      File.basename(f, '.rb')
    end.sort!

    roles.each do |role|
      args = Rake::TaskArguments.new([:name], [role])
      Rake::Task['load:role'].execute(args)
    end
  end

  desc "Upload a single environment definition"
  task :environment, :name do |t, args|
    name = args.name

    e = Chef::Environment.new
    e.name(name)
    e.from_file(File.join(ENVIRONMENTS_DIR, "#{name}.rb"))

    printf "  + %-20s\n", e.name
    e.save
  end

  desc "Upload all environment definitions"
  task :environments do
    puts ">>> Uploading environments"

    environments = Dir[ File.join(ENVIRONMENTS_DIR, '*.rb') ].map do |f|
      File.basename(f, '.rb')
    end.sort!

    environments.each do |environment|
      args = Rake::TaskArguments.new([:name], [environment])
      Rake::Task['load:environment'].execute(args)
    end
  end

  desc "Upload a single databag"
  task :databag, :name do |t, args|
    name = args.name

    puts ">>> Uploading data bag #{name}"

    begin
      b = Chef::DataBag.load(name)
    rescue
      b = Chef::DataBag.new
      b.name(name)
      b.create
      b = Chef::DataBag.load(name)
    end

    items = Dir[ File.join(BAGS_DIR, name, "*.rb") ].map do |f|
      File.basename(f, '.rb')
    end.sort!

    items.each do |item|
      puts("  + #{item}")

      i = Chef::DataBagItem.new
      i.data_bag(name)
      i[:id] = item

      i.create if not b.include?(item)
      i.from_file(File.join(BAGS_DIR, name, "#{item}.rb"))
      i.save
    end
  end

  desc "Upload all data bags"
  task :databags do
    bags = Dir[ File.join(BAGS_DIR, "*/") ].map do |f|
      File.basename(f)
    end.sort!

    bags.each do |bag|
      args = Rake::TaskArguments.new([:name], [bag])
      Rake::Task['load:databag'].execute(args)
    end
  end

end
