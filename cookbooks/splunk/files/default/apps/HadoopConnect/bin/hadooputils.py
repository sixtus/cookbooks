import os,sys,subprocess,time
from util import *
from constants import *
from kerberos import Krb5Principal


def validateHadoopHome(env):
    if 'HADOOP_HOME' not in env:
       raise Exception('HADOOP_HOME is not set. Please configure a valid HADOOP_HOME for this cluster.')

    hadoop_cli = os.path.join(env["HADOOP_HOME"], "bin", "hadoop")
    if not os.path.exists(hadoop_cli):
       raise Exception('Invalid HADOOP_HOME. Cannot find hadoop CLI, path=%s' % hadoop_cli)

    if 'JAVA_HOME' not in env:
       raise Exception('JAVA_HOME is not set. Please configure a valid JAVA_HOME for this cluster.')

    if not os.path.exists(os.path.join(env["JAVA_HOME"], "bin", "java")):
       raise Exception('Invalid JAVA_HOME. Cannot find java executable, path=%s' %  os.path.join(env["JAVA_HOME"], "bin", "java"))



 
def setupHadoopEnv(hadoop_home, java_home, hadoop_conf_dir, krb_principal=None):
    # setup HADOOP_HOME and HADOOP_CONF_DIR 
    # the later is needed for cluster specific configs, such as kerberos support etc
    if hadoop_home == None or len(hadoop_home.strip()) == 0:
       raise Exception('hadoop_home cannot be None, empty or all white space string')
  
    if java_home == None or len(java_home.strip()) == 0:
       raise Exception('java_home cannot be None, empty or all white space string')

    # start with the env we're called in 
    env = dict(os.environ) #copy 

    if hadoop_home != "$HADOOP_HOME":
       env["HADOOP_HOME"] = hadoop_home  

    if java_home != "$JAVA_HOME":
       env["JAVA_HOME"] = java_home

    validateHadoopHome(env)

    if hadoop_conf_dir != None and not len(hadoop_conf_dir.strip()) == 0:
       env["HADOOP_CONF_DIR"] = hadoop_conf_dir

    # make cli stop complaining about HADOOP_HOME
    env["HADOOP_HOME_WARN_SUPPRESS"] = "true"

    # set up environment needed for Kerberos access to Hadoop
    if krb_principal == None or len(krb_principal.strip()) == 0:
       return env 
   
    krb5p = Krb5Principal(krb_principal)
    if not krb5p.isValid():  
       raise Exception('Could not find keytab file=%s for principal=%s' % (krb5p.getKeytabFile(), krb_principal))      

    # set up env for this principal 
    krb5p.setupEnv(env)  
    return env


class HadoopEnvManager(object):
   namespace = None
   user = None
   sessionKey = None
   krb5_principal = None # default principal if None is provided to getEnv
   env = {}  # maps a (host, port, principal) -> hadoop env

   @classmethod
   def init(cls, app, user, sessionKey, krb5_principal=None):
       cls.namespace = app
       cls.user= user
       cls.sessionKey = sessionKey
       cls.krb5_principal = krb5_principal

   @classmethod
   def getEnv(cls, uri, principal=None):
       if cls.namespace == None:
          raise Exception("HadoopEnvManager.init() must be called before getEnv")
       import urlparse
       
       #1. parse uri to get just host:port 
       host = None
       port = None
       p = urlparse.urlparse(uri) 
       if p.scheme == 'hdfs':
          host = p.hostname
          port = str(p.port)  
       else:
          return dict(os.environ)
   
       if principal == None:
          principal = cls.krb5_principal

       key = (host, port, principal) #host, port, principal

       #2. check if env is in cache
       if key in cls.env:
          #TODO: for long running processes we'll need to refresh the TGT if it's too old
          return dict(cls.env[key]) # copy

       #3.use REST to get cluster info from splunkd
       rc = None #result cluster
       hostport = '%s:%s' % (host, port)
       try:
          from splunk.bundle import getConf
          clusters = getConf('clusters', sessionKey=cls.sessionKey, namespace=cls.namespace, owner=cls.user )
          for c in clusters:
              if not c == hostport:
                 continue
              rc = clusters[c]
              break
       except Exception, e:
          logger.error(str(e))
 
       result = None
       if rc == None:
          raise Exception("Could not find configuration for cluster=%s. Please configure the cluster before attempting to use it." % hostport)
       else:
          hadoop_home = rc['hadoop_home']
          java_home   = rc['java_home']
          app_local = os.path.join(os.environ['SPLUNK_HOME'], 'etc', 'apps', APP_NAME, 'local')
          hadoop_conf_dir = os.path.join(app_local, 'clusters', makeFileSystemSafe(hostport))  # use _ instead of : in host:port since : is used as a path separator
          if principal == None:
             principal = rc.get('kerberos_principal', None)

          if principal != None and len(principal.strip()) == 0:
             principal = None


          #TODO: ensure current user has permission to use the given principal
          result = setupHadoopEnv(hadoop_home, java_home, hadoop_conf_dir, principal)
          logger.debug("uri=%s, hadoop_home=%s, java_home=%s" % (uri, result.get('HADOOP_HOME', ''), result.get('JAVA_HOME', '')))
          cls.env[key] = result

       return result

    
def validatePrincipalAndKeytab(principal):
    krb5p = Krb5Principal(principal)
    if not krb5p.isValid():
       raise Exception('Could not find keytab file=%s for principal=%s' % (krb5p.getKeytabFile(), principal))
    env = dict(os.environ)
    krb5p.setupEnv(env)

# 1. set KRB5CCNAME env variable
# 2. verify principal works with given keytab file, generate tgt cache file
# 3. verify service_principal works by listing root directory of remote hadoop server with tgt cache file and service principal   
def validateConnectionToHadoop(sessionKey, principal, uri):
    HadoopEnvManager.init(APP_NAME, 'nobody', sessionKey, principal)
    hj = HadoopCliJob(HadoopEnvManager.getEnv(uri, principal))
    hj.ls(uri)
    if hj.wait() != 0:
        raise Exception('Error while doing fs shell ls command to path %s: %s' % (uri, hj.getStderr()))

def parseHTMLTag(body, lWord, rTag='<tr', extraWord=True):
    v = None
    if extraWord:
        lWord += '<td id="col2"> :<td id="col3">'
    i = body.find(lWord)
    if i > 0:
        j = body[i+len(lWord):].find(rTag)
        if j > 0:
            i += len(lWord)
            v = body[i:i+j].strip()
    return v
        
def toBytes(s):
    if not s: return
    v = float(s[:-2].strip())
    if s[-2:].lower() == 'kb':
        v *= 1024
    if s[-2:].lower() == 'mb':
        v *= 1024 ** 2
    if s[-2:].lower() == 'gb':
        v *= 1024 ** 3
    if s[-2:].lower() == 'tb':
        v *= 1024 ** 4
    if s[-2:].lower() == 'pb':
        v *= 1024 ** 5
    return v    

def getHadoopClusterInfoFromJmx(url):
    info = None
    try:
        import urllib2
        import json
        response = urllib2.urlopen(url)
        json_raw = response.read()
        json_object = json.loads(json_raw)
        info = json_object['beans'][0]
        for k,v in info.iteritems():
            if type(v) is unicode:
                info[k] = str(v)
    except Exception, e:
        logger.warn("Cannot read jmx metrics from url:"+url)
    return info

def getHadoopClusterInfoFromJsp(url):
    info = None
    try:
        import urllib2
        response = urllib2.urlopen(url)
        body = response.read()
        info = {}
        info['Version'] = parseHTMLTag(body, 'Version: <td>', extraWord=False)
        info['Total'] = toBytes(parseHTMLTag(body, 'Configured Capacity'))
        info['Used'] = toBytes(parseHTMLTag(body, 'DFS Used'))
        info['Free'] = toBytes(parseHTMLTag(body, 'DFS Remaining'))
        info['NonDfsUsedSpace'] = toBytes(parseHTMLTag(body, 'Non DFS Used'))
        info['PercenUsed'] = parseHTMLTag(body, 'DFS Used%')
        info['PercentRemaining'] = parseHTMLTag(body, 'DFS Remaining%')
    except Exception, e:
        logger.exception("Cannot parse dfshealth.jsp page from url:"+url)
    return info

def getHadoopClusterInfo(host, port=50070):
    #use wildcard to ensure the query works with Apache and CDH distros
    url = "http://%s:%d/jmx?qry=*adoop:service=NameNode,name=NameNodeInfo" % (host, port)
    info = getHadoopClusterInfoFromJmx(url)
    if not info:
         # if jmx is turned off, try to parse the jsp page
         url = "http://%s:%d/dfshealth.jsp" % (host, port)
         info = getHadoopClusterInfoFromJsp(url)
    return info

def isSecureHadoop(host, port=9000):
    hdl = HDFSDirLister()
    hdl.ls("hdfs://%s:%d/" % (host, port))
    return (hdl.error and hdl.error.find('Authentication is required')>0)

class HadoopCliJob:

   def __init__(self, env):
      validateHadoopHome(env)
      hadoop_home     = env.get("HADOOP_HOME")
      self.hadoop_cli = os.path.join(hadoop_home, "bin", "hadoop")
      self.env        = env
      self.process    = None
      self.rv         = None 
      self.input      = None
      self.starttime  = None  
      self.endtime    = None
      self.fscmd      = None
 
   def popen(self, cmd='fs', shell=False, *options):
        if self.process != None:
           raise Exception("the job is already in progress")
        args = [self.hadoop_cli, cmd]
        if len(options) > 0:
            args.extend(options)
        self.fscmd = options[0]
        self.starttime = time.time()
        self.process = subprocess.Popen(args, shell=shell, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=self.env)
   
   def fsShell(self, *options):
       self.popen('fs', False, *options)
       
   def moveFromLocal(self, src, dst):
       self.fsShell('-moveFromLocal', src, dst)

   def mv(self, src, dst):
       self.fsShell('-mv', src, dst)

   def rm(self, src):
       self.fsShell('-rm', src)
 
   def rmr(self, src):
       self.fsShell('-rmr', src)
 
   def cat(self, src):
       self.fsShell('-cat', src)

   def text(self, src):
       self.fsShell('-text', src)

   def put(self, dst, input):
       self.fsShell('-put', '-', dst)
       self.input = input  

   def get(self, src, localdst):
       self.fsShell('-get', src, localdst)
       
   def touchz(self, src):
       self.fsShell('-touchz', src)

   def ls(self, src):
       self.fsShell('-ls', src)

   def lsr(self, src):
       self.fsShell('-lsr', src)

   def mkdir(self, path):
       self.fsShell('-mkdir', path)

   def setrep(self, path, replication, wait=True, recursive=True):
       args = ['-setrep']
       if wait:
           args.append('-w')
       args.append(str(replication))
       if recursive:
           args.append('-R')
       args.append(path)
       self.fsShell(*args)
       
   def test(self, option, path):
       if option not in ['-e', '-z', '-d']:
           raise Exception('Invalid option %s, only -e, -z, -d are supported' % str(option))
       self.fsShell('-test', option, path)

   def isDir(self, path):
       self.test("-d", path)
       return self.wait() == 0

   def exists(self, path):
       self.test("-e", path)
       return self.wait() == 0

   def poll(self):
       if self.process == None:
          return self.rv
       return self.process.poll()
 
   def wait(self):
       if self.process == None:
          return self.rv
       self.output = self.process.communicate(self.input) # blocks until cli job is done
       self.endtime = time.time()
       self.rv = self.process.returncode
       self.process = None
 
       # mask failure to remove a non-existant file or directory
       if self.rv != 0 and (self.fscmd == "-rm" or self.fscmd == "-rmr") and self.getStderr().lower().find('no such file or directory') > -1:
          self.rv = 0
  
       return self.rv
       
   def getOutput(self):
       return self.output # (stdout, stderr)    

   def getStderr(self, removeDeprecated=True):
       data = self.output[1]
       if removeDeprecated:
          tmp = []
          for l in data.split('\n'):
              if l.find('DEPRECATED:') < 0 and l.find('Warning: $HADOOP_HOME is deprecated') < 0:
                 tmp.append(l)
          data = '\n'.join(tmp)
                        
       return data  

   def getRuntime(self):
       if self.endtime == None or self.starttime == None:
          return 0
       return self.endtime - self.starttime

class HDFSLsEntry:
    def __init__(self, parts):
        self.acl         = parts[0]
        self.replication = 0 if parts[1] == '-' else int(parts[1])
        self.user        = parts[2]
        self.group       = parts[3]
        self.size        = int(parts[4])
        self.date        = parts[5]
        self.time        = parts[6]
        self.path        = parts[7]
        # fix absolute paths, Hadoop 2.0 releases seem to output absolute urls
        # self.path is supposed to be an absolute path from root of HDFS, NOT a url 
        if self.path.startswith('hdfs://'):
           sl_idx = self.path.find('/', 8)
           if sl_idx > 0:
              self.path = self.path[sl_idx:] 


    def isdir(self):
        return self.acl.startswith('d')
 
    def __repr__(self):
       return "{acl=%s, replication=%d, user=%s, group=%s, size=%d, date=%s, time=%s, path=%s}" % (self.acl, self.replication, self.user, self.group, self.size, self.date, self.time, self.path)


class HDFSDirLister:
    def createHadoopCliJob(self, path, krb5_principal):
        return HadoopCliJob(HadoopEnvManager.getEnv(path, krb5_principal))
    
    def __init__(self, raiseAll=True):
        self.raiseAll = raiseAll
        self.error = None
        
    def ls(self, path, krb5_principal=None):
        hj = self.createHadoopCliJob(path, krb5_principal)
        hj.ls(path)
        return self._parseOutput(hj)  
 
    def lsr(self, path, krb5_principal=None):
        hj = self.createHadoopCliJob(path, krb5_principal)
        hj.lsr(path)
        return self._parseOutput(hj)  

    def _parseOutput(self, hj):
        result = []
        for line in hj.process.stdout:
           r = HDFSDirLister._parseLine(line)
           if r:
              yield r
        if hj.wait() != 0:
           self.error = 'Error while waiting for job to complete: %s' % hj.getStderr()
           if self.raiseAll:
              raise Exception(self.error)
 
    @classmethod
    def _parseLine(cls, line):
           parts = line.strip().split(' ')
           parts = [p for p in parts if len(p) > 0] #remove empty strs
           if len(parts) != 8 or parts[0].strip('drwxt-')!='':
              return None
           return HDFSLsEntry(parts)


class HDFSJobWaiter:
   def __init__(self, jobType, maxConcurrent=10):
      self.max_concurrent = maxConcurrent
      self.jobs = []
      self.jobs_total = 0
      self.total_time = 0
      self.job_type = jobType
      self.errors = []

   def wait(self, running=0, raiseOnError=True, suh=None):
         logger.debug("waiting for %d remaining jobs, currently running %d, total ran %s" % (running, len(self.jobs), self.jobs_total))
         max_wait = self.max_concurrent - running
         i = 0
         while max_wait >= 0 and len(self.jobs) > 0:
             finished = []
             # poll jobs first and only wait on finished jobs, otherwise we could be blocked
             # waiting on some long running process while others have finished and become defunct
             for j in self.jobs:
                 rv = j[1].poll()
                 if rv == None: # not done yet
                    continue

                 rv = j[1].wait() # this should return immediately
                 self.total_time += j[1].getRuntime()
                 finished.append(j)
                 if rv != 0:
                    msg = "Error while waiting for %s job key=%s. %s" % (self.job_type, j[0], j[1].getStderr())
                    if raiseOnError:
                       raise Exception(msg)
                    else:
                       self.errors.append(msg)
              
             for j in finished:
                 self.jobs.remove(j)   
             max_wait -= len(finished)
             
             # if we need to wait on more processes and none of them is done, sleep for some time 
             if max_wait > 0 and len(finished) == 0:
                time.sleep(0.250)             
             
             if suh!=None and i%10==0 and self.job_type=='rename':
                 suh.updateMovingStatus()
                 i += 1
                 
   def addJob(self, key, job, raiseOnError=True):
      if len(self.jobs) >= self.max_concurrent:
         self.wait(self.max_concurrent/2, raiseOnError)

      self.jobs.append( [key,job] )
      self.jobs_total += 1
  


class HDFSFileMover:
   def __init__(self):
       self.jobwaiter = HDFSJobWaiter("moveFromLocal", 8)
       self.paths = {} 
       self.start = time.time()
       self.valid_dirs  = {} #dirs that we know already exist, assuming no-one deletes in the mean time

   def _mkdirp(self, dst, krb5_principal):
       last_slash = dst.rfind('/')
       if last_slash < 0:
          return False

       dst_dir = dst[0:last_slash]
       # already exists
       if dst_dir in self.valid_dirs:
          return True

       # try to create the dir
       cli_job = self.createHadoopCliJob(dst_dir, krb5_principal)
       cli_job.mkdir(dst_dir)
       if cli_job.wait() == 0:
          self.valid_dirs[dst_dir] = 1  
          return True

       # failed to create dir, maybe it already exists
       cli_job.test('-d', dst_dir)
       if cli_job.wait() == 0:
          self.valid_dirs[dst_dir] = 1
          return True
        
       # dir does not exist and we can't create it - give up
       return False

   def createHadoopCliJob(self, dst, krb5_principal):
       return HadoopCliJob(HadoopEnvManager.getEnv(dst, krb5_principal))
   
   def move(self, src, dst, krb5_principal=None):
       if src in self.paths:
          return 

       # make destination dir
       self._mkdirp(dst, krb5_principal)

       cli_job = self.createHadoopCliJob(dst, krb5_principal)
       cli_job.moveFromLocal(src, dst)
       self.jobwaiter.addJob(src, cli_job, False)
       self.paths[src] = dst

   def wait(self):
       if len(self.paths) == 0:
          return
       self.jobwaiter.wait(0, False)
       self.paths = {}

   def getErrors(self):
       return self.jobwaiter.errors

   def hasJobs(self):
       return len(self.paths) > 0 
  
   def getJobCount(self):
       return self.jobwaiter.jobs_total

   def getTotalTime(self):
       return self.jobwaiter.total_time
 
   def getWallTime(self):
       if self.jobwaiter.jobs_total > 0 :
          return time.time() - self.start
       return 0


def hdfsPathJoin(*args):
    if len(args) == 0:
       return None
    if len(args) == 1: 
       return args[0]

    result = args[0]
    for a in args[1:]:
        if not result.endswith('/') and not a.startswith('/'):
            result += '/'
        if result.endswith('/') and a.startswith('/'):
            result = result[:-1]
        result += a 
    return result

