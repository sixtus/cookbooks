define :php_extension, :template => nil, :active => true do
  include_recipe "php::base"

  node[:php][:sapi].each do |sapi|
    case sapi
    when "fpm"
      service = "php-fpm"
    when "apache2"
      service = "apache2"
    else
      service = nil
    end

    params[:template] ||= params[:name] + ".ini"

    template "/etc/php/#{sapi}-php#{node[:php][:slot]}/ext/#{params[:name]}.ini" do
      source params[:template]
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, "service[#{service}]" if service
    end

    if params[:active]
      link "/etc/php/#{sapi}-php#{node[:php][:slot]}/ext-active/#{params[:name]}.ini" do
        to "/etc/php/#{sapi}-php#{node[:php][:slot]}/ext/#{params[:name]}.ini"
        notifies :restart, "service[#{service}]" if service
      end
    else
      file "/etc/php/#{sapi}-php#{node[:php][:slot]}/ext-active/#{params[:name]}.ini" do
        action :delete
        notifies :restart, "service[#{service}]" if service
      end
    end
  end
end
