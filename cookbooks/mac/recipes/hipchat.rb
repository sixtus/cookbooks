if mac_os_x?
  mac_package "HipChat" do
    source "http://downloads.hipchat.com.s3.amazonaws.com/osx/HipChat-2.3.zip"
    type "zip_app"
  end
end
