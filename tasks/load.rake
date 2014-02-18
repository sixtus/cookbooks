desc "Pull changes from the remote repository"
task :pull do
  unless ENV.include?('BOOTSTRAP')
    sh("git checkout -q master")
    sh("git pull -q")
  end
end
