execute "chflags nohidden #{node[:homedir]}/Library"

mac_userdefaults "disable window animations" do
  domain "NSGlobalDomain"
  key "NSAutomaticWindowAnimationsEnabled"
  value false
end

mac_userdefaults "disable keyboard press and hold" do
  domain "NSGlobalDomain"
  key "ApplePressAndHoldEnabled"
  value false
end

mac_userdefaults "disable automatic spelling correction" do
  domain "NSGlobalDomain"
  key "NSAutomaticSpellingCorrectionEnabled"
  value false
end

mac_userdefaults "disable menu bar transparency" do
  domain "NSGlobalDomain"
  key "AppleEnableMenuBarTransparency"
  value false
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "expand save panel" do
  domain "NSGlobalDomain"
  key "NSNavPanelExpandedStateForSaveMode"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "expand print panel" do
  domain "NSGlobalDomain"
  key "PMPrintingExpandedStateForPrint"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "show control characters in caret notation" do
  domain "NSGlobalDomain"
  key "NSTextShowsControlCharacters"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "enable full keyboard access to all controls" do
  domain "NSGlobalDomain"
  key "AppleKeyboardUIMode"
  value 3
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "enable subpixel font rendering" do
  domain "NSGlobalDomain"
  key "AppleFontSmoothing"
  value 2
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "show all file extensions" do
  domain "NSGlobalDomain"
  key "AppleShowAllExtensions"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "enable webkit developer extras" do
  domain "NSGlobalDomain"
  key "WebKitDeveloperExtras"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "do not offer timemachine for external drives" do
  domain "com.apple.TimeMachine"
  key "DoNotOfferNewDisksForBackup"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

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

mac_userdefaults "increase window resize speed" do
  domain "NSGlobalDomain"
  key "NSWindowResizeTime"
  value 0.001
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "require password after screensaver" do
  domain "com.apple.screensaver"
  key "askForPassword"
  value 1
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "immediately require password after screensaver" do
  domain "com.apple.screensaver"
  key "askForPasswordDelay"
  value 0
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "show full path in finder window" do
  domain "com.apple.finder"
  key "_FXShowPosixPathInTitle"
  value true
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

mac_userdefaults "enable safari debug menu" do
  domain "com.apple.Safari"
  key "IncludeInternalDebugMenu"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "show finder status bar" do
  domain "com.apple.finder"
  key "ShowStatusBar"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "autohide dock" do
  domain "com.apple.dock"
  key "autohide"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "autohide dock delay" do
  domain "com.apple.dock"
  key "autohide-delay"
  value 0.0
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "autohide time modifier" do
  domain "com.apple.dock"
  key "autohide-time-modifier"
  value 0.25
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "enable spring load actions" do
  domain "com.apple.dock"
  key "enable-spring-load-actions-on-all-items"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "disable launch animations" do
  domain "com.apple.dock"
  key "launchanim"
  value false
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "mouse over hilte stack" do
  domain "com.apple.dock"
  key "mouse-over-hilte-stack"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "show process indicators" do
  domain "com.apple.dock"
  key "show-process-indicators"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "show all files in finder" do
  domain "com.apple.finder"
  key "AppleShowAllFiles"
  value true
end

execute "kill-mac-procs" do
  command "killall Dock Finder SystemUIServer Safari"
  action :nothing
end
