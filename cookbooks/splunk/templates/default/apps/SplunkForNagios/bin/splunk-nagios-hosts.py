#!/opt/splunk/bin/python

# Display all devices in nagios
import os
os.system("/usr/bin/nc <%= @master[:ipaddress] %> 6557 < nagios-hosts")
