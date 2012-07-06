def load_current_resource
  @dmgpkg = Chef::Resource::MacPackage.new(new_resource.name)
  @dmgpkg.app(new_resource.app)
  Chef::Log.debug("Checking for application #{new_resource.app}")
  @dmgpkg.installed(installed?)
end

action :install do
  unless @dmgpkg.installed

    volumes_dir = new_resource.volumes_dir ? new_resource.volumes_dir : new_resource.app
    dmg_name = new_resource.dmg_name ? new_resource.dmg_name : new_resource.app
    file_ext = new_resource.zip ? "zip" : "dmg"
    dmg_file = "#{Chef::Config[:file_cache_path]}/#{dmg_name}.#{file_ext}"
    mnt_path = if new_resource.zip
                 "#{Chef::Config[:file_cache_path]}/#{dmg_name}"
               else
                 "/Volumes/#{volumes_dir}"
               end

    remote_file "#{dmg_file} - #{@dmgpkg.name}" do
      path dmg_file
      source new_resource.source
      checksum new_resource.checksum if new_resource.checksum
      only_if { new_resource.source }
    end

    if new_resource.zip
      execute "unzip -q '#{dmg_file}' -d '#{mnt_path}'"
    else
      passphrase_cmd = new_resource.dmg_passphrase ? "-passphrase #{new_resource.dmg_passphrase}" : ""
      ruby_block "attach #{dmg_file}" do
        block do
          software_license_agreement = system("hdiutil imageinfo #{passphrase_cmd} '#{dmg_file}' | grep -q 'Software License Agreement: true'")
          raise "Requires EULA Acceptance; add 'accept_eula true' to package resource" if software_license_agreement && !new_resource.accept_eula
          accept_eula_cmd = new_resource.accept_eula ? "echo Y |" : ""
          system "#{accept_eula_cmd} hdiutil attach #{passphrase_cmd} '#{dmg_file}'"
        end
        not_if "hdiutil info #{passphrase_cmd} | grep -q 'image-path.*#{dmg_file}'"
      end
    end

    case new_resource.type
    when "app"
      execute "cp -R '#{mnt_path}/#{new_resource.app}.app' '#{new_resource.destination}'"

      file "#{new_resource.destination}/#{new_resource.app}.app/Contents/MacOS/#{new_resource.app}" do
        mode 0755
        ignore_failure true
      end
    when "mpkg", "pkg"
      execute "sudo installer -pkg '#{mnt_path}/#{new_resource.app}.#{new_resource.type}' -target /"
    end

    if new_resource.zip
      execute "rm -rf '#{mnt_path}'"
    else
      execute "hdiutil detach '#{mnt_path}'"
    end
  end
end

private

def installed?
  ::File.directory?("#{new_resource.destination}/#{new_resource.app}.app") ||
    system("pkgutil --pkgs=#{new_resource.package_id}")
end
