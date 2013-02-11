#!/usr/bin/env python

# Example cluster topology script 
# When the hostname is passed as argument
# it prints the rack id to the stdout


import sys 
from string import join 

DEFAULT_RACK = 'default-rack'; 

RACK_MAP = { 
# Add the hosts here in your cluster and remove the comment
#             'host1.mycompany.com' : 'datacenter1-rack0', 
#             'host2.mycompany.com' : 'datacenter2-rack0' 
    } 

if len(sys.argv)==1: 
    print DEFAULT_RACK 
else: 
    print join([RACK_MAP.get(i, DEFAULT_RACK) for i in sys.argv[1:]]," ") 
