require 'chef/node'
require 'chef/data_bag'
require 'chef/data_bag_item'

# monkeypatch data_bag_item for better DSL
class Chef::DataBagItem
  def method_missing(sym, *args, &block)
    self.raw_data.store(sym, *args, &block)
  end
end

task :require_clean_working_tree do
  sh("git update-index -q --ignore-submodules --refresh")
  err = false

  sh("git diff-files --quiet --ignore-submodules --") do |ok, res|
    unless ok
      err = true
      puts("\n** working tree contains unstaged changes:")
      sh("git diff-files --name-status -r --ignore-submodules -- >&2")
    end
  end

  sh("git diff-index --cached --quiet HEAD --ignore-submodules --") do |ok, res|
    unless ok
      err = true
      puts("\n** index contains uncommited changes:")
      sh("git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2")
      puts("")
    end
  end

  err and fail "Working tree is dirty (stash or commit changes)"
end

desc "Pull changes from the remote repository"
task :pull do
  unless ENV.include?('BOOTSTRAP')
    sh("git checkout master")
    sh("git pull")
  end
end

namespace "load" do

  desc "Upload all entities"
  task :all => [ :cookbooks, :nodes, :roles, :databags ]

  desc "Upload a single cookbook"
  task :cookbook => [ :pull ]
  task :cookbook, :name do |t, args|
    sh("knife cookbook upload -o cookbooks #{args.name}")
  end

  desc "Upload all cookbooks"
  task :cookbooks => [ :pull ]
  task :cookbooks do
    sh("knife cookbook upload --all")
  end

  desc "Delete and upload all cookbooks"
  task :cookbooks_clear => [ :pull ]
  task :cookbooks_clear do
    rest = Chef::REST.new(Chef::Config[:chef_server_url])
    rest.get_rest('cookbooks').each do |name, cb|
      puts("Deleting cookbook #{name} ...")
      cb['versions'].each do |vcb|
        puts("  v#{vcb['version']}")
        rest.delete_rest("cookbooks/#{name}/#{vcb['version']}")
      end
    end
    sh("rm -rf #{Chef::Config[:cache_options][:path]}")
    Rake::Task['load:cookbooks'].invoke
  end

  desc "Upload a single node definition"
  task :node => [ :pull ]
  task :node, :fqdn do |t, args|
    fqdn = args.fqdn

    puts("Updating node #{fqdn}")

    begin
      n = Chef::Node.load(fqdn)
    rescue
      n = Chef::Node.new
      n.name(fqdn)
    end

    n.from_file(File.join(NODES_DIR, "#{fqdn}.rb"))
    n.save
  end

  desc "Upload all node definitions"
  task :nodes => [ :pull ]
  task :nodes do
    nodes = Dir[ File.join(NODES_DIR, '*.rb') ].map do |f|
      File.basename(f, '.rb')
    end.sort!

    nodes.each do |node|
      args = Rake::TaskArguments.new([:fqdn], [node])
      Rake::Task['load:node'].execute(args)
    end
  end

  desc "Upload a single role definition"
  task :role => [ :pull ]
  task :role, :name do |t, args|
    name = args.name

    puts("Updating role #{name} ...")

    r = Chef::Role.new
    r.name(name)
    r.from_file(File.join(ROLES_DIR, "#{name}.rb"))
    r.save
  end

  desc "Upload all role definitions"
  task :roles => [ :pull ]
  task :roles do
    roles = Dir[ File.join(ROLES_DIR, '*.rb') ].map do |f|
      File.basename(f, '.rb')
    end.sort!

    roles.each do |role|
      args = Rake::TaskArguments.new([:name], [role])
      Rake::Task['load:role'].execute(args)
    end
  end

  desc "Upload a single databag"
  task :databag => [ :pull ]
  task :databag, :name do |t, args|
    name = args.name

    puts("Uploading data bag #{name} ...")

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
      puts("  > #{item}")

      i = Chef::DataBagItem.new
      i.data_bag(name)
      i[:id] = item

      i.create if not b.include?(item)
      i.from_file(File.join(BAGS_DIR, name, "#{item}.rb"))
      i.save
    end
  end

  desc "Upload all data bags"
  task :databags => [ :pull ]
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
