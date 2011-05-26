include ChefUtils::RVM

action :create do
  rvm = infer_vars(new_resource.name)

  ruby_config = {
    :version => "ruby-1.9.2-p136",
    :libpath => "lib/ruby/site_ruby",
  }.merge(new_resource.ruby_config.symbolize_keys)

  rvm_execute "installing ruby interpreter: #{ruby_config[:version]}" do
    code <<-EOS
    rvm install #{ruby_config[:version]}
    mkdir -p ${rvm_path}/rubies/#{ruby_config[:version]}/#{ruby_config[:libpath]}
    touch ${rvm_path}/rubies/#{ruby_config[:version]}/#{ruby_config[:libpath]}/auto_gem.rb
    EOS

    creates "#{rvm[:path]}/rubies/#{ruby_config[:version]}/#{ruby_config[:libpath]}/auto_gem.rb"
    user rvm[:user]
  end

  portage_preserve_libs "rvm-#{rvm[:user]}" do
    paths [
      "#{rvm[:path]}/rubies",
      "#{rvm[:path]}/gems",
    ]
  end

  if new_resource.default
    rvm_execute "setting default interpreter" do
      code "rvm --default #{ruby_config[:version]}"

      user rvm[:user]
      not_if do
        begin
          ::File.readlink("#{rvm[:path]}/rubies/default") == "#{rvm[:path]}/rubies/#{ruby_config[:version]}"
        rescue
          false
        end
      end
    end
  end
end

action :delete do
  rvm = infer_vars(new_resource.user)
end
