if platform?("mac_os_x")
  mac_package "iTerm" do
    source "http://iterm2.googlecode.com/files/iTerm2-1_0_0_20120203.zip"
    zip true
  end

  mac_userdefaults "hide tab bar when there is only one tab" do
    domain "com.googlecode.iterm2"
    key "HideTab"
    value "1"
  end

  mac_userdefaults "hide border around window" do
    domain "com.googlecode.iterm2"
    key "UseBorder"
    value "0"
  end
end
