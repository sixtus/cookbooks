define :ssl_certificate, :cn => "localhost", :owner => "root", :group => "root", :mode => "0440" do
  include_recipe "openssl"

  %w(key crt).each do |t|
    cookbook_file "#{params[:name]}.#{t}-#{rrand}" do
      path "#{params[:name]}.#{t}"
      owner params[:owner]
      group params[:group]
      mode params[:mode]
      source "certificates/#{params[:cn]}.#{t}"
      cookbook "openssl"
    end
  end
end
