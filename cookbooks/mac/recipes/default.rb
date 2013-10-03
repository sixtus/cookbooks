if platform?("mac_os_x")
  execute "chflags nohidden #{node[:homedir]}/Library"

  include_recipe "mac::global"
  include_recipe "mac::dock"
  include_recipe "mac::finder"

  mac_userdefaults "enable safari debug menu" do
    domain "com.apple.Safari"
    key "IncludeInternalDebugMenu"
    value true
    notifies :run, "execute[kill-mac-procs]"
  end

  execute "kill-mac-procs" do
    command "killall Dock Finder SystemUIServer"
    action :nothing
  end
end
