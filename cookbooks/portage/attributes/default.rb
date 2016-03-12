# paths & directories
default[:portage][:arch] = %x(portageq envvar ARCH 2>/dev/null || :).chomp
default[:portage][:make_conf] = "/etc/portage/make.conf"
default[:portage][:confdir] = "/etc/portage"
default[:portage][:portdir] = "/usr/portage"
default[:portage][:distdir] = "#{node[:portage][:portdir]}/distfiles"
default[:portage][:pkgdir] = "#{node[:portage][:portdir]}/packages/#{node[:portage][:arch]}"

# compiler settings
default[:portage][:CFLAGS] = "-O2 -pipe"
default[:portage][:CXXFLAGS] = "${CFLAGS}"

# advanced features
default[:portage][:OPTS] = %w(--usepkg=y --getbinpkg=y)
default[:portage][:overlays] = {}

# repo settings
if gentoo?
  default[:portage][:repo] = File.read("/usr/portage/profiles/repo_name").chomp

  if node[:portage][:repo] =~ /^zentoo/
    default[:portage][:profile] = "#{node[:portage][:portdir]}/profiles/default/linux/#{node[:portage][:arch]}/zentoo"
    default[:portage][:sync_uri] = "https://github.com/zentoo/zentoo"
  elsif node[:portage][:repo] == "gentoo"
    default[:portage][:profile] = "#{node[:portage][:portdir]}/profiles/default/linux/#{node[:portage][:arch]}/13.0"
    default[:portage][:sync_uri] = "https://github.com/gentoo/gentoo"
  else
    raise "unsupported portage repo: #{node[:portage][:repo]}"
  end
end
