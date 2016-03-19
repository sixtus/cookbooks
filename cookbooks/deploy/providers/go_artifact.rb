include AccountHelpers

use_inline_resources

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  path = user[:dir]

  deploy_s3_file "#{path}/bin/#{nr.user}.current" do
    remote_path nr.remote_path
    bucket nr.bucket
    aws_access_key_id nr.aws_access_key_id
    aws_secret_access_key nr.aws_secret_access_key
    owner nr.user
    group nr.user
    mode "0755"
    notifies :run, "bash[make-versioned-binary]", :immediately
  end

  bash "make-versioned-binary" do
    action :nothing
    user nr.user
    code <<-EOH
    version=$(#{path}/bin/#{nr.user}.current -version)
    cp #{path}/bin/#{nr.user}.current #{path}/bin/#{nr.user}.${version}
    ln -Tfs #{path}/bin/#{nr.user}.${version} #{path}/bin/#{nr.user}
    EOH
  end
end
