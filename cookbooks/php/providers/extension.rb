use_inline_resources

action :create do
  nr = new_resource

  service "php-fpm" do
    action :nothing
  end

  node[:php][:sapi].each do |sapi|
    case sapi
    when "fpm"
      service = "php-fpm"
    else
      service = nil
    end

    source = nr.template
    source ||= nr.name + ".ini"

    template "/etc/php/#{sapi}-php#{node[:php][:slot]}/ext/#{nr.name}.ini" do
      source source
      cookbook nr.cookbook if nr.cookbook
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, "service[#{service}]" if service
    end

    link "/etc/php/#{sapi}-php#{node[:php][:slot]}/ext-active/#{nr.name}.ini" do
      to "/etc/php/#{sapi}-php#{node[:php][:slot]}/ext/#{nr.name}.ini"
      notifies :restart, "service[#{service}]" if service
    end
  end
end

action :delete do
  nr = new_resource

  service "php-fpm" do
    action :nothing
  end

  node[:php][:sapi].each do |sapi|
    case sapi
    when "fpm"
      service = "php-fpm"
    else
      service = nil
    end

    file "/etc/php/#{sapi}-php#{node[:php][:slot]}/ext-active/#{nr.name}.ini" do
      action :delete
      notifies :restart, "service[#{service}]" if service
    end
  end
end
