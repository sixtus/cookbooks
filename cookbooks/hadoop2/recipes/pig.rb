include_recipe "hadoop2"

%w(
  /var/app/hadoop2/pig
  /var/app/hadoop2/pig/contrib
).each do |dir|
  directory dir do
    owner "hadoop2"
    group "root"
    mode "0775"
  end
end

pig_tar = "https://d2ljt3w7wnnuw2.cloudfront.net/pig-#{node[:hadoop2][:pig][:version]}-src.tar.gz"
pig_basedir = "/var/app/hadoop2/pig"
pig_dir = "#{pig_basedir}/pig-#{node[:hadoop2][:pig][:version]}-src"

# bug fix, remove when ant runs w/o it (or dependencies change)
remote_file "/var/app/hadoop2/.m2/repository/org/mortbay/jetty/jetty/6.1.26/jetty-6.1.26.zip" do
  source "https://d2ljt3w7wnnuw2.cloudfront.net/jetty-6.1.26-bundle.zip"
  user "hadoop2"
  group "hadoop2"
end

directory pig_basedir do
  user "hadoop2"
  group "hadoop2"
  mode "0755"
end

tar_extract pig_tar do
  target_dir pig_basedir
  creates pig_dir
  user "hadoop2"
  group "hadoop2"
  notifies :run, "execute[pig-build]", :immediately
end

execute "pig-build" do
  cwd pig_dir
  command "/usr/bin/ant clean jar-withouthadoop -Dhadoopversion=23"
  user "hadoop2"
  group "hadoop2"
  action :nothing
end

contrib_jars = Hash[node[:hadoop2][:pig][:default_jars].map do |contrib_uri|
  [contrib_uri, "/var/app/hadoop2/pig/contrib/#{contrib_uri.split('/')[-1]}"]
end]

contrib_jars.each do |contrib_uri, jar_name|
  remote_file jar_name do
    source contrib_uri

    user "hadoop2"
    group "hadoop2"
  end
end

Dir["/var/app/hadoop2/pig/contrib/*"].each do |file_name|
  unless contrib_jars.values.include? file_name
    file file_name do
      action :delete
    end
  end
end

template "/var/app/hadoop2/current/bin/pig" do
  source "pig.sh"
  owner "root"
  group "hadoop2"
  mode "0755"
end
