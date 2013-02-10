def require_clean_working_tree
  sh("git update-index -q --ignore-submodules --refresh")
  err = false

  sh("git diff-files --quiet --ignore-submodules --") do |ok, res|
    unless ok
      err = true
      puts("\n** working tree contains unstaged changes:")
      sh("git diff-files --name-status -r --ignore-submodules -- >&2")
    end
  end

  sh("git diff-index --cached --quiet HEAD --ignore-submodules --") do |ok, res|
    unless ok
      err = true
      puts("\n** index contains uncommited changes:")
      sh("git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2")
      puts("")
    end
  end

  err and raise "Working tree is dirty (stash or commit changes)"
end
