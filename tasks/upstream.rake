namespace :upstream do

  desc "Initialize private repository and upstream branch"
  task :init, :repo do |t, args|
    if args.repo
      # make private repository the new origin
      sh("git remote rm origin")
      sh("git remote add origin #{args.repo}")
      sh("git push -u origin master")
    end

    # add public cookbooks as upstream branch
    sh("git remote rm upstream || :")
    sh("git remote add -f upstream https://github.com/zenops/cookbooks.git")
    sh("git branch -t upstream upstream/master")
    sh("git config push.default tracking")
  end

  task :pull do
    require_clean_working_tree
    sh("git fetch upstream")
    sh("git branch -f upstream upstream/master")
  end

  desc "Show changes to upstream"
  task :changes => [ :pull ]
  task :changes do
    sh("git diff --diff-filter=DMTUXB upstream master")
  end

  desc "Show new upstream commits"
  task :log => [ :pull ]
  task :log do
    sh("git log --reverse -p master..upstream")
  end

  desc "Merge upstream branch"
  task :merge => [ :pull ]
  task :merge do
    sh("git merge upstream")
  end

end

task :uc => 'upstream:changes'
task :um => 'upstream:merge'
