namespace :upstream do

  desc "Initialize private repository and upstream branch"
  task :init, :repo do |t, args|
    if args.repo
      # make private repository the new origin
      sh("git remote rm origin")
      sh("git remote add origin #{args.repo}")
      sh("git push -u origin master")
    end

    # remove old cruft
    sh("git remote rm upstream || :")
    sh("git branch -D upstream || :")

    # add public cookbooks remote
    sh("git remote rm zenops || :")
    sh("git remote add -f zenops https://github.com/zenops/cookbooks.git")
    sh("git branch -t -f next zenops/next")
    sh("git config push.default tracking")
  end

  task :pull do
    require_clean_working_tree
    sh("git fetch zenops")
    sh("git branch -t -f next zenops/next")
  end

  desc "Merge upstream branch"
  task :merge => [ :pull ]
  task :merge do
    sh("git merge #{UPSTREAM_BRANCH}")
  end

  desc "Show changes to upstream"
  task :changes, :branch do |t, args|
    args.with_defaults(branch: UPSTREAM_BRANCH)
    sh("git diff --diff-filter=DMTUXB #{args.branch} HEAD")
  end

  desc "Show missing picks from upstream"
  task :cherry, :upstream  do |t, args|
    args.with_defaults(upstream: UPSTREAM_BRANCH)
    limit = %x(git show --oneline ":/^Merge branch '#{args.upstream}'")
            .split($/).first
            .split(/\s/).first
    sh("git cherry -v #{args.upstream} HEAD #{limit}")
  end
end

task :uc => 'upstream:changes'
task :um => 'upstream:merge'
