include_recipe "java"

package "dev-java/gradle-bin"

deploy_skeleton "kafka"

deploy_application "kafka" do
  repository node[:kafka][:git][:repository]
  revision node[:kafka][:git][:revision]

  before_symlink do
    execute "kafka-gradle" do
      command "/usr/bin/gradle"
      cwd release_path
      user "kafka"
      group "kafka"
    end

    execute "kafka-build" do
      command "#{release_path}/gradlew jar"
      cwd release_path
      user "kafka"
      group "kafka"
    end
  end
end

directory "/var/app/kafka/current/libs" do
  owner "root"
  group "kafka"
  mode "0750"
end

template "/var/app/kafka/current/config/log4j.properties" do
  source "log4j.properties"
  owner "root"
  group "kafka"
  mode "0640"
  notifies :restart, "service[kafka]"
end

template "/var/app/kafka/current/config/tools-log4j.properties" do
  source "log4j.properties"
  owner "root"
  group "kafka"
  mode "0640"
  notifies :restart, "service[kafka]"
end

template "/usr/bin/kafka" do
  source "kafka.sh"
  owner "root"
  group "root"
  mode "0755"
end
