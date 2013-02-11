import os
import splunk.admin as admin
from clusters import Cluster
from delegating_handler import DelegatingRestHandler
from util import logger
import constants

required_args = ['namenode_http_port', 'hadoop_home', 'java_home']  # required on create
optional_args = ['kerberos_principal', 'kerberos_service_principal']

ENDPOINT = 'configs/conf-clusters'

class ClustersHandler(DelegatingRestHandler):
    
    def setup(self):
        self.appName = constants.APP_NAME
        self.userName = 'nobody'
        if self.requestedAction == admin.ACTION_LIST:
           self.supportedArgs.addOptArg('add_versions')
        elif self.requestedAction == admin.ACTION_EDIT or self.requestedAction == admin.ACTION_CREATE:
             for arg in optional_args:
                 self.supportedArgs.addOptArg(arg)
             for arg in required_args:
                 if self.requestedAction == admin.ACTION_EDIT:
                     self.supportedArgs.addOptArg(arg)
                 else:
                     self.supportedArgs.addReqArg(arg)  

        
    def handleList(self, confInfo):
        self.delegate(ENDPOINT, confInfo, method='GET')
        # add some runtime information to the items
        for name, obj in confInfo.items():
            cluster = Cluster(name, obj)
            obj['cluster_dir'] = cluster.getClusterDir()
            obj['cluster_cli'] = cluster.hadoop_cli
            obj['authentication_mode'] = 'simple' if obj.get('kerberos_principal', '') == '' else 'kerberos'
            obj['authorization_mode']  = '0'      if obj.get('kerberos_principal', '') == '' else '1'
            if self.callerArgs.get('add_versions', [''])[0] == '1': 
               local = 'unknown'
               remote = 'unknown'
               try:
                   local = cluster.getLocalHadoopVersion() 
               except: pass
               try: 
                   remote = cluster.getRemoteHadoopVersion() 
               except: pass 
               obj['local_hadoop_version'] = local
               obj['remote_hadoop_version'] = remote
        
    def handleCreate(self, confInfo):
        import splunk.entity as en
        if en.getEntities('admin/conf-clusters', search='name='+self.callerArgs.id, namespace=self.appName, owner=self.userName, sessionKey=self.getSessionKey()):
            raise Exception('%s already exists, cannot create it again!' % self.callerArgs.id)
        conf = en.getEntity('admin/conf-clusters', '_new', namespace=self.appName, owner=self.userName, sessionKey=self.getSessionKey())
        cluster = self.validateArgs(conf)
        self.callerArgs.id = cluster.name
        self.callerArgs['host'] = str(cluster.host)
        self.callerArgs['namenode_ipc_port'] = str(cluster.namenode_ipc_port)
        try:
            logger.info(confInfo)
            self.handleCreateOrEdit(cluster, confInfo)
        except Exception as e:
            logger.exception("Failed to handleCreate:")
            # remove created dir and xml file
            cluster.remove()
            # delete new stanza if exists
            if en.getEntities('admin/conf-clusters', search=self.callerArgs.id, namespace=self.appName, owner=self.userName, sessionKey=self.getSessionKey()):
                en.deleteEntity('admin/conf-clusters', self.callerArgs.id, namespace=self.appName, owner=self.userName, sessionKey=self.getSessionKey())
            raise e

        
    def handleEdit(self, confInfo):
        import splunk.entity as en
        conf = en.getEntity('admin/conf-clusters', self.callerArgs.id, namespace=self.appName, owner=self.userName, sessionKey=self.getSessionKey())
        cluster = self.validateArgs(conf)
        try:
            self.handleCreateOrEdit(cluster, confInfo)
        except Exception as e:
            logger.exception("Failed to handleEdit")
            # rollback to previous xml file
            cluster.props['authentication_mode']        = conf['authentication_mode']
            cluster.props['authorization_mode']         = conf['authorization_mode']
            cluster.props['kerberos_service_principal'] = conf['kerberos_service_principal'] if 'kerberos_service_principal' in conf else None
            cluster.props['kerberos_principal']         = conf['kerberos_principal']         if 'kerberos_principal'         in conf else None
            cluster.saveXml()
            # rollback to previous stanza
            for k,v in self.callerArgs.items():
                self.callerArgs[k] = conf[k]
            self.delegate(ENDPOINT, confInfo)
            raise e
    
    def validateArgs(self, conf):
        namenode_http_port = int(self.getProperty('namenode_http_port', conf))
        hadoop_home = self.getProperty('hadoop_home', conf)
        java_home = self.getProperty('java_home', conf)
        
        authentication_mode = 'simple'
        authorization_mode  = '0'
        
        principal = self.getProperty('kerberos_principal', conf)
        kerberos_service_principal = self.getProperty('kerberos_service_principal', conf)
        if kerberos_service_principal != None and kerberos_service_principal.strip() != '':
            authentication_mode = 'kerberos'
            authorization_mode  = '1'

        props = {'namenode_http_port':namenode_http_port, 
                 'hadoop_home': hadoop_home, 
                 'java_home': java_home, 
                 'authentication_mode':authentication_mode, 
                 'authorization_mode':authorization_mode, 
                 'principal':principal, 
                 'kerberos_service_principal':kerberos_service_principal}
        cluster = Cluster(self.callerArgs.id, props)
        return cluster
    
    def handleCreateOrEdit(self, cluster, confInfo):
        # 1) create local/clusters/<host_port> directory if not exists 2) verify hadoop version 3) create/update core-site.xml
        cluster.save()

        # remove fields we don't want to save in the conf file
        fields = ['name', 'namenode_http_port', 'kerberos_principal', 'kerberos_service_principal', 'hadoop_home', 'java_home']
        for k in self.callerArgs.keys():
            if not k in fields:
               del self.callerArgs[k]
         
        # create/edit conf stanza
        self.delegate(ENDPOINT, confInfo)
        
        principal = cluster.props['principal'] if  cluster.props['authentication_mode'] == 'kerberos' else None
        import hadooputils as hu
        # verify kerberos_principal, keytab and kerberos_service_principal and ls works
        hu.validateConnectionToHadoop(self.getSessionKey(), principal, 'hdfs://'+self.callerArgs.id+'/')
    
    def handleRemove(self, confInfo):
        # delegate remove to /servicesNS/<user>/<app>/admin/conf-clusters
        self.delegate(ENDPOINT, confInfo, method='DELETE')
        cluster = Cluster(self.callerArgs.id)
        cluster.remove()
   
    def handleCustom(self, confInfo):
        method = 'GET' if self.requestedAction == admin.ACTION_LIST else 'POST'
        self.delegate(ENDPOINT, confInfo, method=method, customAction=self.customAction)

    def getProperty(self, name, conf):
        value = None
        if name in self.callerArgs:
            value = self.callerArgs[name]   
        elif name not in conf:
            raise Exception('%s is required' % name)
        else:
            value = conf[name]
        if type(value) is list:
            value = value[0]
        
        if type(value) is str:
            value = value.strip()
            if len(value) == 0:
                value = None
            
        return value
    
        
admin.init(ClustersHandler, admin.CONTEXT_APP_ONLY)
 
