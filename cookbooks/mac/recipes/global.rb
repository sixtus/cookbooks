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
