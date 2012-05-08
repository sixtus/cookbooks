require "highline/import"

namespace :generate do

  desc "Generate a cookbook skeleton"
  task :cookbook do
    name = ask('Cookbook name: ') do |q|
      q.validate = /^\w+$/
    end

    description = ask('Cookbook description: ')

    maintainer = %x(git config user.name).chomp
    maintainer_email = %x(git config user.email).chomp

    cb_path = File.join(COOKBOOKS_DIR, name)
    FileUtils.mkdir_p(cb_path)

    File.open(File.join(cb_path, "metadata.rb"), "w") do |f|
      f.write <<EOS
description "#{description}"

maintainer "#{maintainer}"
maintainer_email "#{maintainer_email}"
license "Apache v2.0"
EOS
    end

    FileUtils.mkdir_p(File.join(cb_path, "recipes"))

    %w(files templates).each do |d|
      FileUtils.mkdir_p(File.join(cb_path, d, "default"))
    end

    File.open(File.join(cb_path, "recipes", "default.rb"), "w") do |f|
      f.write "# add some resources here\n"
    end
  end

end
