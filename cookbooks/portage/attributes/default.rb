# paths & directories
set[:portage][:arch] = %x(portageq envvar ARCH 2>/dev/null || :).chomp
set[:portage][:make_conf] = "/etc/portage/make.conf"
set[:portage][:confdir] = "/etc/portage"
set[:portage][:portdir] = "/usr/portage"
set[:portage][:distdir] = "#{set[:portage][:portdir]}/distfiles"
set[:portage][:pkgdir] = "#{set[:portage][:portdir]}/packages/#{node[:portage][:arch]}"

# compiler settings
default[:portage][:CFLAGS] = "-O2 -pipe"
default[:portage][:CXXFLAGS] = "${CFLAGS}"

# build-time flags
default[:portage][:USE] = []

# advanced masking
default[:portage][:ACCEPT_KEYWORDS] = nil

# advanced features
default[:portage][:FEATURES] = []
default[:portage][:OPTS] = %w(--usepkg=y --getbinpkg=y)
default[:portage][:MAKEOPTS] = "-j1"

# language support
default[:portage][:LINGUAS] = %w(en)

# repo settings
if gentoo?
  set[:portage][:repo] = File.read("/usr/portage/profiles/repo_name").chomp

  if node[:portage][:repo] =~ /^zentoo/
    default[:portage][:profile] = "#{set[:portage][:portdir]}/profiles/default/linux/#{node[:portage][:arch]}/11.0"

    default[:portage][:SYNC] = "rsync://mirror.zenops.net/zentoo-portage"
    default[:portage][:BINHOST] = "http://mirror.zenops.net/zentoo/${ARCH}/packages"
    default[:portage][:MIRRORS] = %w(
    http://mirror.zenops.net/zentoo
    http://ftp.spline.de/pub/gentoo
    )
  elsif node[:portage][:repo] == "gentoo"
    default[:portage][:profile] = "#{set[:portage][:portdir]}/profiles/default/linux/#{node[:portage][:arch]}/13.0"

    default[:portage][:SYNC] = "rsync://rsync.de.gentoo.org/gentoo-portage"
    default[:portage][:MIRRORS] = %w(
    http://ftp.spline.de/pub/gentoo
    )
  else
    raise "unsupported portage repo: #{node[:portage][:repo]}"
  end
end
