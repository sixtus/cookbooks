#!/bin/sh
sed -e '/^To:/d' -e 's/^Subject:/OUTPUT/' | \
	/usr/bin/systemd-cat -t crond -p err
