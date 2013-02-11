import os
import sys 

import splunk
import splunk.search

SSLIST = ['__generate_lookup_hadoop_host2rack',
            '__generate_lookup_hadoop_host2mapred', 
            '__generate_lookup_hadoop_host2maxcpu', 
            '__generate_lookup_hadoop_host2hdfs']

APP_NAME = __file__.split(os.sep)[-4]
APP_DIR = (os.sep).join(__file__.split(os.sep)[0:-4])
CSV = os.path.join(APP_DIR, 'lookups', 'hadoop_host2rack.csv') 

if __name__ == '__main__':

    token = sys.stdin.readlines()[0]
    token = token.strip()

    if not os.path.isfile(CSV):
        for ss in SSLIST:
            job = splunk.search.dispatch(' | savedsearch %s' % ss, sessionKey=token, namespace=APP_NAME)
            splunk.search.waitForJob(job)
            job.cancel()

