import splunk.admin as admin
from util import logger

required_args = ['uri', 'search']
optional_args = ['base_path', 'roll_size', 'minspan', 'maxspan', 'starttime', 'endtime', 'format', 'fields', 'partition_fields', 'kerberos_principal', 'parallel_searches', 'cron_schedule'] 

ENDPOINT = 'configs/conf-export'

class HDFSExportHandler(admin.MConfigHandler):
    '''HDFSExportHandler is a MConfigHandler to manage jobs that will export data from a search command to Hadoop file system'''

    def setup(self):
        '''assign required and optional parameters for create and update'''
        if self.requestedAction in [admin.ACTION_CREATE, admin.ACTION_EDIT] and self.customAction == '':
            for arg in required_args:
                if self.requestedAction == admin.ACTION_CREATE:
                   self.supportedArgs.addReqArg(arg)
                else:
                   self.supportedArgs.addOptArg(arg)

            for arg in optional_args:
                self.supportedArgs.addOptArg(arg)

    def getEntity(self, entityPath, entityName):
        import splunk.entity as en
        return en.getEntity(entityPath, entityName, namespace=self.appName, owner=self.userName, sessionKey=self.getSessionKey())
        
    def getEntities(self, entityPath, search=None):
        import splunk.entity as en
        return en.getEntities(entityPath, namespace=self.appName, owner=self.userName, search=search, sessionKey = self.getSessionKey())
            
    def handleNew(self, confInfo):
        confnew = self.getEntity('admin/conf-export', '_new')
        confItem = confInfo[self.callerArgs.id]
        for key, val in confnew.items():
            confItem[key] = str(val) if val else ''
    
    def handleList(self, confInfo):
        '''Provide a list of export jobs with needed information about the search'''
        # hack to support unicode in our objects 
        admin.str = unicode

        # hack to get around external REST handlers not supporting _new
        # and conf-<file> handlers not exposing default stanza
        if self.callerArgs.id == '_new_ext' or self.callerArgs.id == "default":
           self.handleNew(confInfo)
           return

        # Read custom conf file - export.conf
        searchItems = self.getEntities('saved/searches', "name=ExportSearch:*")
        exportItems = self.getEntities('admin/conf-export')

        for name, obj in exportItems.items():
            ssName = 'ExportSearch:%s' % name
            if not ssName in searchItems:
                  continue

            confItem = confInfo[name]
            try:
                confItem.update(searchItems[ssName])
                del confItem['eai:acl']
            except KeyError:
                pass
            for key, val in obj.items():
                confItem[key] = str(val)
            acl = {}
            for k, v in obj[admin.EAI_ENTRY_ACL].items():
                if None != v:
                    acl[k] = v
            confItem.setMetadata(admin.EAI_ENTRY_ACL, acl)


    def handleCreate(self, confInfo):
        '''Create a new HDFS export job.  Save the export.conf information and a saved search'''
        name = self.callerArgs.id
        if name == "default":
           del self.callerArgs['search']
           self.handleEdit(confInfo)
           return

        # validate search
        if len(self.callerArgs['search']) == 0 or not self.callerArgs['search'][0] or len(self.callerArgs['search'][0].strip()) == 0: 
           raise admin.ArgValidationException('search cannot be an empty string or contain only whitespace characters') 

        # validate cron schedule and parallel searches
        cron_schedule     = self.callerArgs.get('cron_schedule', ['0 * * * *'])[0]
        parallel_searches = self.callerArgs.get('parallel_searches', ['1'])[0]  
        if not parallel_searches == "max":
           try:
               if int(parallel_searches) < 1:
                  raise Exception
           except:
               raise admin.ArgValidationException('Invalid parallel_searches. Must be a positive number or "max"')

        
        # see if the search can be parsed....if it can't an exception will be shown the user.
        query = self.callerArgs['search'][0].strip()
        if not query[0] == '|' and not query.startswith('search'):
            query = 'search ' + query
        self.parseSearch(query)
        
        #check to see if the hdfs path supplied is valid
        uri = self.callerArgs.data.get('uri', [''])[0].strip()
        bp = self.callerArgs.data.get('base_path', [''])[0].strip()
        if not (uri.startswith('hdfs://') or uri.startswith('file://')):  
           raise admin.ArgValidationException('Invalid uri %s. It must be hdfs://<server>:<port> or file://<local-dir>' % uri)
        if len(bp) == 0:
            raise admin.ArgValidationException('Base path cannot be empty or all white space')
        
        # make sure format is supported
        format = self.callerArgs.data.get('format', [''])[0].strip()
        if len(format) > 0 and format not in ['raw', 'json', 'xml', 'csv', 'tsv']:
            raise admin.ArgValidationException('Invalid format %s. It must be one of these: raw, json, xml, csv, tsv' % format)
            
        # validate kerberos principal before creating anything
        self.validatePrincipal()

        #we also save a scheduled saved search to do the ongoing export
        params = {}
        params["name"]          = 'ExportSearch:%s' % name
        params['search']        = '| runexport name="%s"' %  name
        self.saveSearch(name, params, cron_schedule)

        if 'cron_schedule' in self.callerArgs: 
            del self.callerArgs['cron_schedule']
        #finally we should save the export.conf stanza 
        self.writeConf('export', name, self.callerArgs)
    
    def saveSearch(self, name, params, cron_schedule):
        from splunk.models.saved_search import SavedSearch
        saved_search = SavedSearch(self.appName, self.userName, sessionKey=self.getSessionKey(), **params)
        saved_search.schedule.is_scheduled = True
        saved_search.schedule.cron_schedule = cron_schedule
        # hack around saved search model not supporting these fields
        saved_search.entity.properties['description']   = 'Scheduled search for export job: %s' % name
        saved_search.entity.properties['is_visible']    = '0'

        if not saved_search.save():
            raise Exception("Error while saving scheduled search")
        
    def parseSearch(self, query):
        try:
            import splunk.search.Parser as Parser
            parsedSearch = Parser.parseSearch(str(query), sessionKey=self.getSessionKey())
            searchProps = parsedSearch.properties.properties
            if len(searchProps.get("reportsSearch", "")) > 0:
               raise Exception("Cannot export a reporting search")
        except Exception, e:
            raise admin.ArgValidationException('Invalid search: ' + str(e))
        
    def handleEdit(self, confInfo):
        '''Edit the export.conf entry'''
        # handle "default" entity via properties endpoint because conf-<file> does not list default stanza
        if self.callerArgs.id == "default":
           from splunk.bundle import getConf
           myConf = getConf('export', sessionKey=self.getSessionKey(), namespace=self.appName, owner='nobody' )
           myConf.beginBatch()
           for k,v in self.callerArgs.data.iteritems():
                  if type(v) is list:
                      if len(v) == 0:
                         continue
                      else:
                         v = v[0]
                  if v != None and v != 'None':
                     myConf['default'][k] = v.strip()
          
           myConf.commitBatch() 
        else:
           self.validatePrincipal()
           self.writeConf('export', self.callerArgs.id, self.callerArgs)

    def handleRemove(self, confInfo):
        '''Delete the export.conf job and the associated saved search'''
        import splunk.entity as en
        name = self.callerArgs.id
        searchName = 'ExportSearch:%s' % name

        en.deleteEntity('saved/searches', searchName,
                        namespace=self.appName,
                        owner=self.userName,
                        sessionKey = self.getSessionKey())
        en.deleteEntity(ENDPOINT, name,
                        namespace=self.appName,
                        owner=self.userName,
                        sessionKey = self.getSessionKey())

    def getSavedSearch(self, name):
       import splunk.models.saved_search as sm_saved_search
       ent = self.getEntity('saved/searches', name)
       ss = sm_saved_search.SavedSearch.manager()._from_entity(ent)
       ss.sessionKey = self.getSessionKey()
       return ss

    def handleCustom(self, confInfo):
        if not self.requestedAction == admin.ACTION_EDIT: 
           self.invalidCustomAction()

        searchName = 'ExportSearch:' + self.callerArgs.id
        ss = self.getSavedSearch(searchName)

        if self.customAction == "pause":
           ss.schedule.is_scheduled = False
           ss.save()
        elif self.customAction == "resume":
           ss.schedule.is_scheduled = True
           ss.save()
           self.writeConf('export', self.callerArgs.id, {'status': 'done'})
        elif self.customAction == "force":
           url = ss.entity.getLink('reschedule')
           if url == None: 
              raise admin.BadActionException, "Could not find a reschedule entity link on the saved search object."
           import splunk.rest as rest
           response, content = rest.simpleRequest(url, method='POST', sessionKey=self.getSessionKey())
           if response.status != 200:
              raise admin.BadActionException, "Unexpected status code %d was returned from saved search endpoint" % (response.status)
        else:
           self.invalidCustomAction() 

    def validatePrincipal(self):
        principal = None
        try:
           if 'kerberos_principal' in self.callerArgs:
               principal = self.callerArgs['kerberos_principal']
           if principal and type(principal) is list:
               principal = principal[0]    
           if principal and len(principal) > 0:
              import hadooputils as hu
              hu.validatePrincipalAndKeytab(principal.strip())
        except Exception, e:
              raise admin.ArgValidationException('Failed to validate Kerberos principal. %s' % (str(e)))
 
if __name__ ==  '__main__':
   admin.init(HDFSExportHandler, admin.CONTEXT_APP_AND_USER)
