"""
External search command for writing chunks of data locally and then moving them over to hdfs 
"""

import os,time,sys,time,gzip
from util import *
from hadooputils import * 
from constants import *
from export_formatter import * 



class FinishSearchException(Exception):
  def __init__(self, msg):
    Exception.__init__(self, msg)


class BufferedFile:
    """Simple class that holds data in memory and flushes it out
       to a file once the buffer size is reached """
    def __init__(self, path, compress=0, maxbuf=DEFAULT_BUFFER_SIZE):
        self.max_total=maxbuf
        self.strs=[]
        self.total_size = 0
        self.path = path   
        self.size_on_disk = None
        self.compress = compress
 
    def write(self, s):
        self.total_size += len(s)
        self.strs.append(s)
        if self.total_size > self.max_total:
           self.flush()

    def flush(self):
          dir = os.path.dirname(self.path)
          if not os.path.isdir(dir):
             os.makedirs(dir)
          if self.path.endswith('.gz'):
             f = gzip.open(self.path, 'ab', compresslevel=self.compress)  # yes, we can append to gz files
          else:
             f = open(self.path, 'a')
            
          f.write(''.join(self.strs))
          f.close()
          
          self.strs = []   
          self.total_size = 0   
          self.size_on_disk = None    
          
    def tell(self):
        if self.size_on_disk == None and os.path.exists(self.path):
           self.size_on_disk = os.stat(self.path).st_size
         
        if self.size_on_disk == None:
           self.size_on_disk = 0
        
        if self.path.endswith('.gz'):
           return self.size_on_disk + self.total_size/8  # estimate compressed size

        return self.size_on_disk + self.total_size 

    def close(self):
        self.flush()
     

   

# 1. write the results into a temporary file
# 2. when the file grows too big or this is the last time we're being called
#    ship the data over to hadoop
class SplunkResultHandler(BaseSplunkResultHandler):
    def __init__(self, formatter):
        BaseSplunkResultHandler.__init__(self)
        self.formatter  = formatter
        self.ishdfs     = True
        self.uri        = None  # hdfs://foobar:123 or file://
        self.uri_path   = None  # /this/comes/after/uri
        self.tmp_dir    = None  # either tmp dir or final destination for file://
        self.dstpath_idx = None # several indexes into the search results passed to us
        self.source_idx = None
        self.host_idx   = None
        self.hdfs_mover = HDFSFileMover() 
        self.open_files = {}
        self.unflush_percent = DEFAULT_UNFLUSH_PERCENT # percentage of unflushed data when disk usage reach to limit
        self.roll_size  = DEFAULT_ROLL_SIZE     # max local file size before rolling to hdfs
        self.max_local  = 0                     # max local disk usage
        self.local_bytes = 0                    # total bytes written
        self.local_time = 0.000                 # time spent writing to local file system
        self.hdfs_time = 0.000                  # time spent writing to hdfs file system
        self.hdfs_bytes  = 0            		# number of bytes sent to hdfs
        self.parent_sid  = None         		# the search id of our parent
     
        self.buffer_size = DEFAULT_BUFFER_SIZE  # max size before flushing to disk
        self.rolled_ext = DEFAULT_ROLL_EXTENSION       
        self.temp_chunk_filename = LOCAL_CHUNK_FILE_NAME
        self.base_filename = ''        # base name for rolled files
        self.script_call_counter = 0   # the number of times the search has called this script
        self.rolled_file_count = 0     # number of files rolled by the script
        self.hdfs_file_count = 0       # number of files moved to hdfs during this invocation
        self.compress = 2 # the compression level to use
        
    def raiseException(self, msg):        
        self.info.finalizeSearch()
        self.info.addErrorMessage(msg)
        self.info.writeOut()
        raise FinishSearchException(msg)  
   
    def checkParentSearchStatus(self):
        if not self.parent_sid: 
           return
     
        import splunk.search
        msg = None
        try:
            sj = splunk.search.getJob(self.parent_sid, sessionKey=self.sessionKey)
            if sj._cachedProps['isDone'] or sj._cachedProps['isFinalized'] or sj._cachedProps['isZombie'] or sj._cachedProps['isFailed']:
               msg = "Parent job, search_id=%s is not running. Stopping..." % (self.parent_sid)
        except Exception, e:
            msg = "Error while getting parent's search status, search_id=%s. Stopping... %s" % (self.parent_sid, str(e)) 
            logger.exception(msg)

        if msg:
           self.raiseException(msg)

    def checkPreconditions(self, argvals):

        if not 'basefilename' in argvals:
            self.raiseException("basefilename needs to be provided")
            
        if not 'dst' in argvals:
           self.raiseException("dst needs to be provided")
        dst = unquote(argvals['dst'])
        try:       
            uri, uri_path = getBaseURIAndPath(dst)
        except Exception as e:
            logger.exception(str(e))
            self.raiseException(str(e))
        if uri.startswith("file://") and not os.path.isabs(uri_path):
              self.raiseException("The destination needs to be an absolute path: %s" % (uri_path))
       
        if 'tmp_dir' in argvals and not os.path.isabs(argvals['tmp_dir']):
            self.raiseException("tmp_dir needs to be an absolute path: %s" % argvals['tmp_dir'])
        
        return dst, uri, uri_path
    
    def handleInfo(self, infoPath):
        self.info  = SearchResultsInfo()
        self.info.readFrom(infoPath)
        # if search has already ran into some errors we want to stop any export
        err_msgs = self.info.getErrorMessages() 
        if len(err_msgs) > 0:
            self.raiseException("Search has ran into %d error(s), stopping export!" % (len(err_msgs)))
            
    # there's an issue with 4.3.4 with dispatchtmp being disabled by default
    # but the search process still tries to use it and it finds out that the dir does not exist
    # so here we try to create  $SPLUNK_HOME/var/run/splunk/dispatchtmp/<sid>
    # NOTE: we do not needed to delete this as Splunk's reaper will take care of it
    def disptachtmpWorkAround(self, settings):
        if  not settings.get('splunkVersion', '').startswith('4.3.4'):
           return
        dispatchtmp_dir = os.path.join(os.environ['SPLUNK_HOME'], 'var', 'run', 'splunk', 'dispatchtmp', settings.get('sid'))
        if os.path.isdir(dispatchtmp_dir):
           return   
        try:
            os.makedirs(dispatchtmp_dir)
        except:
            pass

    # called once, after reading any settings send by search
    def handleSettings(self, settings, keywords, argvals):
        # applied only in Splunk 4.3.4
        self.disptachtmpWorkAround(settings)

        self.handleInfo(settings.get('infoPath', ''))
        
        argvals['dst'], self.uri, self.uri_path = self.checkPreconditions(argvals)

        self.sessionKey = settings.get('sessionKey', None)
        self.owner      = settings.get('owner',      None)
        self.namespace  = settings.get('namespace',  None)
        
        #TODO: check info is valid at this point
            
        # get roll and max local disk usage size from cmd line - it's in MB
        self.roll_size     = int(argvals.get('rollsize', DEFAULT_ROLL_SIZE))*1024*1024
        self.max_local     = int(argvals.get('maxlocal', DEFAULT_MAX_LOCAL_SIZE))*1024*1024
        self.parent_sid    = unquote(argvals.get('parentsid', None))
        self.base_filename = unquote(argvals.get('basefilename', ''))
        self.export_name   = unquote(argvals.get('exportname', ''))
        self.krb5_principal = unquote(argvals.get('kerberos_principal', '')).strip()


        if len(self.krb5_principal) == 0:
           self.krb5_principal = None
        HadoopEnvManager.init(APP_NAME, 'nobody', self.sessionKey, self.krb5_principal)


        # compress by default
        self.compress = int(argvals.get('compress', '2'))
        if self.compress > 0:
            self.rolled_ext          = '.gz' + self.rolled_ext
            self.temp_chunk_filename = self.temp_chunk_filename + '.gz'

        dispatch_dir   = getDispatchDir(self.info.get('_sid'), settings.get('sharedStorage', None))
        self.tmp_dir = argvals['tmp_dir'] if 'tmp_dir' in argvals else DEFAULT_HDFS_TMP_DIR_NAME    
        # handle write to local files
        if self.uri.startswith("file://"):
           self.tmp_dir = self.uri_path
           self.ishdfs  = False
        else:   
           self.tmp_dir = os.path.join(dispatch_dir, self.tmp_dir)

        if not os.path.exists(self.tmp_dir):
           os.makedirs(self.tmp_dir)
   
        format = unquote(argvals.get('format', '')).strip()
        fields = unquote(argvals.get('fields', '')).strip().split(',')
        if len(format) != 0:
           self.rolled_ext = '.' + format + self.rolled_ext 
           try:
               self.formatter = ResultFormatter.get(format, [x.strip() for x in fields])
           except Exception, e:
               self.raiseException(str(e))

        # flush to hdfs every 10 calls
        max_idle_time = 10*60 
        
        if self.info.countMap:
           self.script_call_counter = int(self.info.countMap.get('invocations.command.exporthdfs', '0'))        

        if self.script_call_counter % 10 == 0:
           #use disk usage information provided by the search to ensure we don't go over max_local
           self.flushToHdfs(self.getToFlushFilesIfReachLimit(dispatch_dir), 0)
           
           # roll files that have not been written to in a while
           self.rollFilesByMtime(time.time() - max_idle_time)
           self.flushToHdfs(self.getToFlushFiles())

           # see if our parent is still alive
           self.checkParentSearchStatus()

    # called once, after reading the result header
    def handleHeader(self, header):
        self.header = header
        self.formatter.setHeader(header)
        if "_dstpath" in header:
           self.dstpath_idx = header.index('_dstpath') 
        if 'host'  in header:
           self.host_idx = header.index('host')            
        if 'source'  in header:
           self.source_idx = header.index('source')
        return None


    def getDestPath(self, result):
        dstpath = '' 
        if self.dstpath_idx != None:
           dstpath  = result[self.dstpath_idx]

        #TODO: throw up if we can't create the dst path because either _dstpath is missing or the components we need are missing

        if len(dstpath) == 0:
           source = result[self.source_idx].lstrip(os.sep) # make path relative to root
           dstpath = os.path.join(result[self.host_idx], source)
           #TODO: ensure that the computed path is a relative


        # if dstpath is absolute it will override the first part - this takes care of the leading '/'
        dstpath = os.path.join(self.uri_path, dstpath, self.temp_chunk_filename)
        # when in hdfs mode we need to write to the tmp dir (/tmp_dir/final/path/in/hdfs/) 
        if self.ishdfs: 
           dstpath = self.tmp_dir + dstpath
        return dstpath

 
    # called for each result read in
    def handleResult(self, result):
        dstpath = self.getDestPath(result)
        self.appendToFile(self.formatter.format(result), dstpath)
        return None

    # called once, after reading all results
    def handleFinish(self):
        # time closing files, since that includes last flush
        s_time = float(time.time())
        self.closeAllFiles()
        self.local_time += float(time.time() - s_time)

        query_finished = int(self.info.get('_query_finished'))
        if query_finished != 0:
            self.rollAllFiles()
            self.flushToHdfs(self.getToFlushFiles(), 0)
                
        self.waitForHdfsJobs(False)
       
        #self.hdfs_time       = self.hdfs_mover.getTotalTime()
        self.hdfs_time       = self.hdfs_mover.getWallTime()
        self.hdfs_file_count = self.hdfs_mover.getJobCount()
        if self.info.countMap:
           if self.local_bytes > 0:
              self.info.updateMetric('command.exporthdfs.local', int(self.local_time*1000))
           if self.hdfs_file_count > 0:
              self.info.updateMetric('command.exporthdfs.hdfs', int(self.hdfs_time*1000), self.hdfs_file_count)
        self.info.writeOut()

    def appendToFile(self, data, file):
       dst = file 
       s_time = float(time.time())
       f = self.open_files.get(file, None)
       if f == None:
          f = BufferedFile(file, self.compress, self.buffer_size)
          self.open_files[file] = f
       f.write(data)
       f.write('\n')
       
       if self.roll_size > 0 and f.tell() > self.roll_size:
          f.close()
          del self.open_files[file]
          dst = self.rollFile(file)
       e_time = float(time.time())
       self.local_time += float(e_time - s_time)
       self.local_bytes += len(data)
       return dst
   
    def rollFile(self, file):
        dir  = os.path.dirname(file)
        tstr = self.base_filename
        if len(tstr) == 0:
           tstr = "%d_%d_%d" % (int(time.time()), self.script_call_counter, self.rolled_file_count)
        else:
           tstr = "%s_%d_%d" % (tstr, self.script_call_counter, self.rolled_file_count)
        dst = os.path.join(dir, tstr + self.rolled_ext)
        os.rename(file, dst);
        self.rolled_file_count += 1
        return dst
   
    def rollFilesByMtime(self, maxmtime):
        count = 0
        for root, dirs, files in os.walk(self.tmp_dir):
            for name in files:
                if name.endswith(self.rolled_ext):
                   continue
                if maxmtime == 0 or os.stat(os.path.join(root, name)).st_mtime < maxmtime:
                   self.rollFile(os.path.join(root, name))
                   count += 1
        return count
 
    def rollAllFiles(self):
        self.rollFilesByMtime(0)
    
    def closeAllFiles(self):
        for n,f in self.open_files.iteritems():
           f.close()

    def getToFlushFiles(self):
        toflush = {}
        for root, dirs, files in os.walk(self.tmp_dir):
            for name in files:
                if not name.endswith(self.rolled_ext):
                    continue
                
                local_path = os.path.join(root, name)
                toflush[local_path] = self.getHdfsPath(local_path)
        return toflush
            
    def getToRollFiles(self):
        toroll = []
        for root, dirs, files in os.walk(self.tmp_dir):
            for name in files:
                if name.endswith(self.rolled_ext):
                    continue
                toroll.append(os.path.join(root, name))
        return toroll
            
    def getToFlushFilesIfReachLimit(self, dispatch_dir):
        statusPath = os.path.join(dispatch_dir, 'status.csv')
        if not os.path.exists(statusPath):
            self.raiseException('Failed to get status information')
            
        with open(statusPath, 'r') as f:
            r = csv.reader(f)
            status_header = r.next()
            if 'disk_usage' not in status_header:
                self.raiseException('Failed to get disk usage information')
                
            status = r.next()
            disk_usage = int(status[status_header.index('disk_usage')])
            ptoflush = {}
            
            if self.max_local == 0 or disk_usage < self.max_local:
               return ptoflush

            minFlushSize = disk_usage - self.max_local * self.unflush_percent / 100
            #when reach to limit, flush largest files until disk usage is below the given percentage of allowed limit
            candidates = self.getToFlushFiles()
            filesizes = {}
            for path in candidates.iterkeys():
                filesizes[path] = os.path.getsize(path)
            flushSize = 0    
            for path, size in sorted(filesizes.iteritems(), key=lambda (k,v): v, reverse=True):
                flushSize += size
                ptoflush[path] = candidates[path]
                if flushSize >= minFlushSize:
                   break

            #when we're still over disk usage level here, start rolling the biggest files
            if flushSize < minFlushSize:
                candidates = self.getToRollFiles()
                filesizes = {}
                for path in candidates:
                    filesizes[path] = os.path.getsize(path)
                for path, size in sorted(filesizes.iteritems(), key=lambda (k,v): v, reverse=True):
                    flushSize += size
                    local_path = self.rollFile(path)
                    ptoflush[local_path] = self.getHdfsPath(local_path)
                    if flushSize >= minFlushSize:
                        break
                
            return ptoflush
                                     
    def getHdfsPath(self, local_path):
        return self.uri + local_path[len(self.tmp_dir):]
        
    # walk self.tmp_dir recursively and move all .hdfs files to HDFS
    #TODO: ensure that we only spawn a few hadoop jobs
    def flushToHdfs(self, toflush, minFiles=5):
        if not self.ishdfs or toflush==None:
            return
        
        if len(toflush) >= minFiles:
           for src,dst in toflush.iteritems():
               self.hdfs_bytes += os.path.getsize(src)
               self.hdfs_mover.move(src, dst)
    
    # wait for all the hadoop cli jobs to complete 
    def waitForHdfsJobs(self, writeInfo=True):
        if not self.ishdfs or not self.hdfs_mover.hasJobs():
            return
        
        self.hdfs_mover.wait()
        for err in self.hdfs_mover.getErrors():
            #TODO: improve error message
            self.info.addErrorMessage(err)
            self.info.finalizeSearch()
        if writeInfo:
           self.info.writeOut()

def run_streamer():
  formatter = ResultFormatter.get("raw", ['_raw']) #default formatter
  srh = SplunkResultHandler(formatter)
  srs = SplunkResultStreamer(srh)
  try:
     srs.run()
     srh.waitForHdfsJobs()
  except FinishSearchException, e:
     raise
  except Exception, ex:
     srh.raiseException(str(ex))  
  

  if srh.local_bytes > 0 or srh.hdfs_bytes > 0:
     logger_metrics.info("group=transfer, export_name=\"%s\", sid=%s, events=%d, local_KB=%d, local_time=%.3f, hdfs_KB=%d, hdfs_time=%.3f, hdfs_files=%d" % 
                        (srh.export_name, srh.info.get("_sid"), srs.total_events, int(srh.local_bytes/1024), srh.local_time, int(srh.hdfs_bytes/1024), srh.hdfs_time, srh.hdfs_file_count))

if __name__ == '__main__':  
    try:
        run_streamer()
    except FinishSearchException, e:
        sys.stderr.write(str(e))


