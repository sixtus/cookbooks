import os, os.path
import splunk.admin as admin

class DelegatingRestHandler(admin.MConfigHandler):
 
  # delegate to /servicesNS/<user>/<app>/admin/conf-principals
  def delegate(self, delegate_endpoint, confInfo, method='POST', customAction='', args={}):
      import splunk.entity as en
      import splunk.rest as rest

      user = self.context == admin.CONTEXT_APP_AND_USER and self.userName or "nobody"

      if self.requestedAction == admin.ACTION_CREATE:
         uri = en.buildEndpoint(delegate_endpoint, namespace=self.appName, owner=user)
         args['name'] = self.callerArgs.id
      else:
         uri = en.buildEndpoint(delegate_endpoint, entityName=self.callerArgs.id, namespace=self.appName, owner=self.userName)

      if len(customAction) > 0:
         uri += '/' + customAction

      for k,v in self.callerArgs.items():
          if k.startswith('_'):
             continue
          if isinstance(v, list):
             args[k] = v[0]
          else:
             args[k] = v 

      if method == 'GET':
         app  = self.context != admin.CONTEXT_NONE         and self.appName  or "-"
         user = self.context == admin.CONTEXT_APP_AND_USER and self.userName or "-"

         thing=en.getEntities(None, uri=uri, sessionKey=self.getSessionKey(), namespace=app, owner=user, count=-1)
         for name, obj in thing.items():
             ci = confInfo[name]
             for key, val in obj.items():
                 if not key.startswith('eai:'):
                    ci[key] = str(val) if val else ''
            
             # fix perms
             if 'perms' in obj['eai:acl'] and not obj['eai:acl']['perms']:
                obj['eai:acl']['perms'] = {}
 
             ci.copyMetadata(obj)
      else:
         serverResponse, serverContent = rest.simpleRequest(uri, sessionKey=self.getSessionKey(), postargs=args, method=method, raiseAllErrors=True)

