import time,sys,urlparse,csv,os,logging.handlers

def createLogger(name, level, filename, format, rotateSize=25*1024*1024, bkCount=4):
    logger = logging.getLogger(name)
    logger.setLevel(level)
    filename = os.path.join(os.environ['SPLUNK_HOME'], 'var', 'log', 'splunk', filename)
    handler = logging.handlers.RotatingFileHandler(filename, maxBytes=rotateSize, backupCount=bkCount)
    formatter = logging.Formatter(format)
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    return logger

logger_metrics = createLogger("hdfsexport.metrics", logging.INFO, 'export_metrics.log', '%(asctime)s - %(message)s')
logger = createLogger("hdfsexport.default", logging.INFO, 'HadoopConnect.log', '%(asctime)s %(levelname)s %(filename)s [%(funcName)s] [%(lineno)s] - %(message)s')

# change field size limit to 1MB
csv.field_size_limit(1 * 1024 * 1024 * 1024)

def splitList(arr, parts=2):
    length = len(arr)
    parts  = min(parts, length)
    return [ arr[ int(i*length/parts) : int((i+1)*length / parts)] for i in range(parts) ]


def makeFileSystemSafe(path):
    #NOTE: ':' is safe but it can cause problems because it is used as path separator
    return path.replace(':', '_').replace('/', '__')

def unquote(s):
    if type(s) is not str:
        return s
    if s == '' or s == None:
        return s 
    elif s.startswith("'"):
        return s.lstrip("'").rstrip("'")
    elif s.startswith('"'):
        return s.lstrip('"').rstrip('"')
    else: 
        return s
    
def getDispatchDir(sid, sharedStorage=None):
    dispatch_dir = sharedStorage
    if dispatch_dir == None:
        dispatch_dir = os.environ['SPLUNK_HOME'] 
    dispatch_dir   = os.path.join(dispatch_dir, 'var', 'run', 'splunk', 'dispatch', sid)
    return dispatch_dir
        
def getBaseURI(uri):
    p = urlparse.urlparse(uri)
    if p.scheme == '' or p.scheme == None:
        raise Exception('invalid uri: ' + uri)
    if  not (uri.startswith('file://') or uri.startswith('hdfs://')):
        raise Exception('unsupported scheme (only file:// and hdfs:// are supported): ' + uri)
    if p.scheme == 'file':
        return 'file://'
    return p.scheme + '://' + p.netloc

def getBaseURIAndPath(uri):
    base_uri = getBaseURI(uri)
    uri_path = uri[len(base_uri):]
    return base_uri, uri_path
        
def writeToCSV(w, row=None):
    if row == None:
        w.writeheader()
    else:
        w.writerow(row)   

##### START: yanked from Intersplunk.py so we avoid having to import it - (takes ~20ms to import) ##### 
def win32_utf8_argv():
    """Uses shell32.GetCommandLineArgvW to get sys.argv as a list of UTF-8                                           
    strings.                                                                                                         
                                                                                                                     
    Versions 2.5 and older of Python don't support Unicode in sys.argv on                                            
    Windows, with the underlying Windows API instead replacing multi-byte                                            
    characters with '?'.                                                                                             
                                                                                                                     
    Returns None on failure.                                                                                         
                                                                                                                     
    Example usage:                                                                                                   
                                                                                                                     
    >>> def main(argv=None):                                                                                         
    ...    if argv is None:                                                                                          
    ...        argv = win32_utf8_argv() or sys.argv                                                                  
    ...                                                                                                              
    """

    try:
        from ctypes import POINTER, byref, cdll, c_int, windll
        from ctypes.wintypes import LPCWSTR, LPWSTR

        GetCommandLineW = cdll.kernel32.GetCommandLineW
        GetCommandLineW.argtypes = []
        GetCommandLineW.restype = LPCWSTR

        CommandLineToArgvW = windll.shell32.CommandLineToArgvW
        CommandLineToArgvW.argtypes = [LPCWSTR, POINTER(c_int)]
        CommandLineToArgvW.restype = POINTER(LPWSTR)

        cmd = GetCommandLineW()

        argc = c_int(0)
        argv = CommandLineToArgvW(cmd, byref(argc))
        if argc.value > 0:
            # Remove Python executable if present                                                                    
            if argc.value - len(sys.argv) == 1:
                start = 1
            else:
                start = 0
            return [argv[i].encode('utf-8') for i in
                    xrange(start, argc.value)]
    except Exception:
        pass

# from sys.argv, get key=value args as well as other plain keyword args (e.g. "file")
def getKeywordsAndOptions():
    import re
    keywords = []
    kvs = {}
    first = True

    # SPL-30670 - handle unicode args specially in windows
    argv = win32_utf8_argv() or sys.argv

    # for each arg
    for arg in argv:
        if first:
            first = False
            continue
        # handle case where arg is surrounded by quotes
        # remove outter quotes and accept attr=<anything>
        if arg.startswith('"') and arg.endswith('"'):
            arg = arg[1:-1]
            matches = re.findall('(?:^|\s+)([a-zA-Z0-9_-]+)\\s*(::|==|=)\\s*(.*)', arg)
        else:
            matches = re.findall('(?:^|\s+)([a-zA-Z0-9_-]+)\\s*(::|==|=)\\s*((?:[^"\\s]+)|(?:"[^"]*"))', arg)
        if len(matches) == 0:
            keywords.append(arg)
        else:
            # for each k=v match
            for match in matches:
                attr, eq, val = match
                # put arg in a match
                kvs[attr] = val
    return keywords,kvs

##### END: yanked from Intersplunk.py so we avoid having to import it !!! ##### 



        
class SearchResultsInfo:
    def __init__(self):
        self.header = []
        self.info = {}
        self.messages = []
        self.dirty = False
        self.path  = None
        self.countMap = None 

    def readFrom(self, path):
        self.path = path
        with open(path, 'r') as f:
            r = csv.reader(f)
            self.header = r.next()
            self.info = dict(zip(self.header, r.next()))

            # parse _countMap
            if "_countMap" in self.info:
               p = self.info["_countMap"].split(';')
               m = {}
               for i in range(0, len(p)-1, 2):
                   m[p[i]] = p[i+1]
               self.countMap = m

            try:
                while True:
                    msg = dict(zip(self.header, r.next()))
                    self.messages.append(msg);
            except StopIteration, sp:
                pass       

    def updateMetric(self, metric, spent_ms, inv=1):
         if not self.countMap:
            return 
         self.countMap['invocations.' + metric ] = int(self.countMap.get('invocations.'+metric, '0')) + inv
         self.countMap['duration.' + metric]     = int(self.countMap.get('duration.'+metric, '0')) + spent_ms
         self.dirty = True

    def checkAndAddHeaderCols(self, cols):
        for k in cols:
            if not k in self.header:
               self.header.append(k)

    def serializeTo(self, out):
        if self.countMap != None:
           p = []
           for k,v in self.countMap.iteritems():
               p.append(str(k))
               p.append(str(v))
           self.info["_countMap"] = ';'.join(p) + ';'

        #ensure the keys are all present in the header
        self.checkAndAddHeaderCols(self.info.keys())
        for m in self.messages:
            self.checkAndAddHeaderCols(m.keys())

        w = csv.DictWriter(out, fieldnames=self.header, restval='')
        writeToCSV(w)
        writeToCSV(w, self.info)
        for m in self.messages: 
            writeToCSV(w, m)

    def writeOut(self):
        if not self.dirty or self.path == None:
           return
      
        tmp_path = self.path + '.tmp'
        with open(tmp_path, 'w') as f:
           self.serializeTo(f)

        os.rename(tmp_path, self.path)
        
        # update atime/mtime of the file so search process reloads the info
        next_sec = (time.time() + 1)
        os.utime(self.path, (next_sec, next_sec))   
 
    def get(self, name, def_val=None):
        return self.info.get(name, def_val)

    def set(self, name, val):
        self.info[name] = val
        self.dirty = True

    def finalizeSearch(self):
       self.set('_request_finalization', '1')
       self.set('_query_finished', '1')
       
    def addErrorMessage(self, msg):
        self.addMessage("ERROR", msg)

    def addWarnMessage(self, msg):
        self.addMessage("WARN", msg)

    def addInfoMessage(self, msg):
        self.addMessage("INFO", msg)

    def addDebugMessage(self, msg):
        self.addMessage("DEBUG", msg)

    def addMessage(self, type, msg):
        self.messages.append({"msgType": type, "msg": msg})
        self.dirty = True
     
    def getErrorMessages(self):
        return self.getMessages("ERROR")

    def getWarnMessages(self):
        return self.getMessages("WARN")

    def getInfoMessages(self):
        return self.getMessages("INFO")

    def getDebugMessages(self):
        return self.getMessages("DEBUG")
    
    def getMessages(self, type):
        result = [] 
        for msg in self.messages:
            if msg.get('msgType', '') == type:
               result.append(msg.get('msg', ''))

        return result
    


class BaseSplunkResultHandler:
    def __init__(self):
       pass

    # called with settings sent by search process
    def handleSettings(self, settings, keywords, argvals):
        pass

    # called with csv header, should return header to output or None  
    def handleHeader(self, header):
        return None

    # called for each results, should return the result to output or None  
    def handleResult(self, result):
        return None
     
    # called after last result is read in, should return a list of results to output or None  
    def handleFinish(self):
        return None


class SplunkResultStreamer:
   def __init__(self, handler, din=sys.stdin, dout=sys.stdout):
      self.settings = {}
      self.header   = []
      self.handler  = handler
      self.din      = din
      self.dout     = dout 
      self.total_events = 0     #total number of events processed
      pass

   def populateSettings(self, file=sys.stdin):
       for line in file:
          if line == '\n':
              break
          parts = line.strip().split(':', 1)
          if len(parts) != 2:
             continue
          parts[1] = urlparse.unquote(parts[1])
          self.settings[parts[0]] = parts[1]   
          
   def run(self):

       #1. read settings
       self.populateSettings(file=self.din)

       #TODO: parse authString XML
       keywords, argvals = getKeywordsAndOptions()
       self.handler.handleSettings(self.settings, keywords, argvals)

       cr = csv.reader(self.din)
       cw = csv.writer(self.dout)
       
       try:
          #2. csv: read header
          self.header = cr.next()
          out_header = self.handler.handleHeader(self.header)
          if out_header != None:
              self.dout.write('\n')  # end output header section
              writeToCSV(cw, out_header)
                  
          #3. csv: read input results
          for row in cr:
              out_row = self.handler.handleResult(row)
              if out_row != None and out_header != None:
                  writeToCSV(cw, out_row)
              self.total_events += 1    
       except StopIteration, sp:
          pass
       finally:       
          #4. get any rows withheld by the handle until it sees finish
          out_rows = self.handler.handleFinish()
          if out_rows != None and out_header != None:
              for out_row in out_rows:
                  writeToCSV(cw, out_row)



