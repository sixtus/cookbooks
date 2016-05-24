include_recipe "java"

deploy_skeleton "gobblin"

deploy_application "gobblin" do
  repository node[:gobblin][:git][:repository]
  revision node[:gobblin][:git][:revision]

  before_symlink do
    execute "build gobblin" do
      command "./gradlew clean build -PuseHadoop2 -PhadoopVersion=#{node[:hadoop2][:version]} -PexcludeHadoopDeps -x test"
      cwd release_path
      user "gobblin"
      group "gobblin"
    end

    execute "unpack dist tar" do
      command "/bin/tar xfz gobblin-distribution-*.tar.gz"
      cwd release_path
      user "gobblin"
      group "gobblin"
    end
  end
end

# needs double chef run before first usage
Dir.glob("/var/app/gobblin/current/gobblin-dist/bin/*.sh") do |s|
  file "/var/app/gobblin/bin/#{s.split('/')[-1]}" do
    content %Q{#!/bin/bash
export HADOOP_CLASSPATH=`/var/app/hadoop2/current/bin/yarn classpath`
export HADOOP_BIN_DIR=/var/app/hadoop2/current/bin
exec #{s} $@
}
    owner "gobblin"
    group "gobblin"
    mode "0555"
  end
end
