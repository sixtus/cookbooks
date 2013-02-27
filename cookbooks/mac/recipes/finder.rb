mac_userdefaults "do not warn while changing file extensions" do
  domain "com.apple.finder"
  key "FXEnableExtensionChangeWarning"
  value false
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "disable .DS_Store for network drives" do
  domain "com.apple.desktopservices"
  key "DSDontWriteNetworkStores"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "show full path in finder window" do
  domain "com.apple.finder"
  key "_FXShowPosixPathInTitle"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "disable disk image verification" do
  domain "com.apple.frameworks.diskimages"
  key "skip-verify"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "disable disk image verification (locked)" do
  domain "com.apple.frameworks.diskimages"
  key "skip-verify-locked"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "disable disk image verification (remote)" do
  domain "com.apple.frameworks.diskimages"
  key "skip-verify-remote"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "open a new finder window on mount" do
  domain "com.apple.frameworks.diskimages"
  key "auto-open-ro-root"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "open a new finder window on rw mount" do
  domain "com.apple.frameworks.diskimages"
  key "auto-open-rw-root"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "open a new finder window on mounts" do
  domain "com.apple.finder"
  key "OpenWindowForNewRemovableDisk"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "disable file quarantine" do
  domain "com.apple.LaunchServices"
  key "LSQuarantine"
  value false
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "disable finder animations" do
  domain "com.apple.finder"
  key "DisableAllAnimations"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "show finder status bar" do
  domain "com.apple.finder"
  key "ShowStatusBar"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "show all files in finder" do
  domain "com.apple.finder"
  key "AppleShowAllFiles"
  value false
end

mac_userdefaults "do not offer timemachine for external drives" do
  domain "com.apple.TimeMachine"
  key "DoNotOfferNewDisksForBackup"
  value true
  notifies :run, "execute[kill-mac-procs]"
end
