#!/bin/bash

for device in /dev/sd?; do
	echo "=== Checking $device ==="
	smartctl -i $device | grep -q Serial

	if [[ $? -eq 0 ]]; then
		smartctl -i -H -A $device | tail -n+4 | grep -v ^===
	else
		echo "!!! Failed to get disk serial. Dumping mdstat and dmesg ..."
		echo
		grep $(basename $device) /proc/mdstat && echo
		dmesg | grep $(basename $device) | tail -n 30
	fi

	echo
done | less
