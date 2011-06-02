define :php_extension, :template => nil, :active => true do
  include_recipe "php"

  %w(cli fpm).each do |sapi|
    template "/etc/php/#{sapi}-php#{PHP.slot}/ext/#{params[:name]}.ini" do
      source params[:template]
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, "service[php-fpm]"
    end

    if params[:active]
      link "/etc/php/#{sapi}-php#{PHP.slot}/ext-active/#{params[:name]}.ini" do
        to "/etc/php/#{sapi}-php#{PHP.slot}/ext/#{params[:name]}.ini"
        notifies :restart, "service[php-fpm]"
      end
    else
      file "/etc/php/#{sapi}-php#{PHP.slot}/ext-active/#{params[:name]}.ini" do
        action :delete
        notifies :restart, "service[php-fpm]"
      end
    end
  end
end
