default[:dovecot][:use_flags] = %w(sieve)
default[:dovecot][:auth][:modules] = %w(system)
default[:dovecot][:sieve][:path] = "~/.dovecot.sieve"
