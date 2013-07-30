define :spawn_fcgi do
  p = {
    :children => 1,
    :chdir => '',
  }.merge(params.symbolize_keys)

  p[:socket] = {
    :path => "/run/spawn-fcgi/#{params[:name]}.sock",
    :address => "127.0.0.1",
    :user => "nobody",
    :group => "nobody",
    :mode => "0660",
  }.merge(p[:socket].symbolize_keys)

  include_recipe "spawn-fcgi"

  name = p[:name]

  systemd_unit "spawn-fcgi-#{name}.service" do
    template "spawn-fcgi.service"
    cookbook "spawn-fcgi"
    variables p
  end

  service "spawn-fcgi@#{name}" do
    action [:disable, :stop]
  end

  service "spawn-fcgi-#{name}" do
    action [:enable, :start]
  end
end
