define :portage_preserve_libs do
  if root?
    directory "/etc/portage/preserve-libs.d-#{rrand}" do
      path "/etc/portage/preserve-libs.d"
      owner "root"
      group "root"
      mode "0755"
    end

    file "/etc/portage/preserve-libs.d/#{params[:name]}" do
      content "#{params[:paths].join("\n")}\n"
      owner "root"
      group "root"
      mode "0644"
    end
  end
end
