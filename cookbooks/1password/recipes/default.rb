if platform?("mac_os_x")
  mac_package "1Password" do
    source "https://d13itkw33a7sus.cloudfront.net/dist/1P/mac/1Password-3.8.20.zip"
    zip true
  end
end
