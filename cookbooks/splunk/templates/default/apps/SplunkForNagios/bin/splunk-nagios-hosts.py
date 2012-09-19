#!/opt/splunk/bin/python

# Display all devices in nagios
import os
os.system("/usr/bin/nc <%= @master[:ipaddress] rescue nil %> 6557 < nagios-hosts")
