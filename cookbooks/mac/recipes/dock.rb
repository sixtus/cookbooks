mac_userdefaults "autohide dock" do
  domain "com.apple.dock"
  key "autohide"
  value true
  notifies :run, "execute[kill-mac-procs]"
end

mac_userdefaults "autohide dock delay" do
  domain "com.apple.dock"
  key "autohide-delay"
  value 0
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
