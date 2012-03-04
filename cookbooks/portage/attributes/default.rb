# paths & directories
set[:portage][:make_conf] = "/etc/make.conf"
set[:portage][:confdir] = "/etc/portage"
set[:portage][:portdir] = "/usr/portage"
set[:portage][:distdir] = "#{set[:portage][:portdir]}/distfiles"
set[:portage][:pkgdir] = "#{set[:portage][:portdir]}/packages/${ARCH}"

# profile
default[:portage][:profile] = "#{set[:portage][:portdir]}/profiles/default/linux/amd64/11.0"

# compiler settings
default[:portage][:CFLAGS] = "-O2 -pipe"
default[:portage][:CXXFLAGS] = "${CFLAGS}"

# build-time flags
default[:portage][:USE] = []

# advanced masking
default[:portage][:ACCEPT_KEYWORDS] = nil

# mirror settings
default[:portage][:SYNC] = "rsync://rsync.zentoo.org/zentoo-portage"
default[:portage][:MIRRORS] = %w(
http://www.zentoo.org
http://ftp.spline.de/pub/gentoo
)

# advanced features
default[:portage][:OPTS] = []
default[:portage][:MAKEOPTS] = "-j1"

# language support
default[:portage][:LINGUAS] = %w(en)
