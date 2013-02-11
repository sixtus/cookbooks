# Copyright (C) 2005-2011 Splunk Inc. All Rights Reserved.  Version 4.0
#
# coding=utf-8
#
#

import subprocess
import splunk.Intersplunk
import sys 
import splunk.util as util
import os

DEFAULT_ARGS = {
    'jthost': 'localhost',
    'script': ''
}

# merge any passed args
args = DEFAULT_ARGS
for item in sys.argv:
    kv = item.split('=')
    if len(kv) > 1:
        val = item[item.find('=') + 1:]
        try:
            val = int(val)
        except:
            pass
        args[kv[0]] = util.normalizeBoolean(val)

# output results
results,unused1,unused2 = splunk.Intersplunk.getOrganizedResults()


for r in results:
    hostname = r['host']
    process = subprocess.Popen( args['script']+ ' '  + hostname, 
	shell=True,stdout=subprocess.PIPE)
    r['rack_name'] = process.stdout.readline().strip() 

splunk.Intersplunk.outputResults(results)
