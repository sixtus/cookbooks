require "highline/import"

namespace :generate do

  desc "Generate a cookbook skeleton"
  task :cookbook do
    name = ask('Cookbook name: ') do |q|
      q.validate = /^\w+$/
    end

    description = ask('Cookbook description: ')
    platforms = ask('Cookbook platforms: ').split(/\s/)
    platforms = %w(gentoo) if platforms.empty?

    maintainer = %x(git config user.name).chomp
    maintainer_email = %x(git config user.email).chomp

    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'metadata.rb')))

    cb_path = File.join(COOKBOOKS_DIR, name)
    FileUtils.mkdir_p(cb_path)

    File.open(File.join(cb_path, "metadata.rb"), "w") do |f|
      f.puts(erb.result(b))
    end

    FileUtils.mkdir_p(File.join(cb_path, "recipes"))

    %w(files templates).each do |d|
      FileUtils.mkdir_p(File.join(cb_path, d, "default"))
    end

    File.open(File.join(cb_path, "recipes", "default.rb"), "w") do |f|
      f.write "# add some resources here\n"
    end
  end

  task :metadata do
    generate_metadata
  end

  desc "Generate the production environment"
  task :env => :metadata do
    env = File.open(File.join(ENVIRONMENTS_DIR, "production.rb"), "w")
    env.printf %{description "The production environment"\n\n}

    cookbook_metadata.each do |cookbook, metadata|
      platforms = metadata[:platforms].keys - CHEF_SOLO_PLATFORMS
      version = metadata[:version]

      next if platforms.empty?

      env.printf %{cookbook %-20s "= %s"\n}, %{"#{cookbook}",}, version
    end

    env.close
  end

end
