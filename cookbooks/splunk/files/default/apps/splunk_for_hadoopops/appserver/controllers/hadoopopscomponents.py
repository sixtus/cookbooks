try:
    import xml.etree.cElementTree as et 
except:
    import xml.etree.ElementTree as et

import logging
import os
import re
import sys
import time
import json
import copy

import cherrypy

import splunk
import splunk.rest
from splunk.search import *
from splunk.util import uuid4

import splunk.appserver.mrsparkle.controllers as controllers
import splunk.appserver.mrsparkle.lib.util as util

from splunk.appserver.mrsparkle.lib.decorators import expose_page
from splunk.appserver.mrsparkle.lib.routes import route

dir = os.path.join(util.get_apps_dir(), __file__.split('.')[-2], 'bin')
if not dir in sys.path:
    sys.path.append(dir)
    
from hadoopops.util.timesince import *
from hadoopops.models.components import Components 

logger = logging.getLogger('splunk.appserver.controllers.hadoopopscomponents')

class HadoopOpsComponents(controllers.BaseController):
    ''' Hadoop Ops Components Controller '''

    # keep track of currently impacted components
    components_created = []
    components_updated = []
    components_deleted = []

    @route('/:action=discover')
    @expose_page(must_login=True, methods=['GET']) 
    def discover(self, action, **kwargs):
        '''Discover & return all current components, i.e. host-service pairs'''

        user = cherrypy.session['user']['name'] 
        app = cherrypy.request.path_info.split('/')[3]
        
        output_mode = kwargs.get('output_mode', 'html')

        #apply hardcoded search
        #sessionKey  = splunk.auth.getSessionKey("admin", "changed")
        #searchcmd = "`hadoop_ps` | kv hadoop_service_type  | rename service_type as services | stats count by host services"
        #search = splunk.search.searchAll(searchcmd)

        # dispatch saved search
        start = time.time()
        try:
            job = splunk.saved.dispatchSavedSearch('__retrieve_live_components', None, app, 'admin')
        except Exception, e:
            logger.error('failed to dispatch discovery search: %s' % job)
            return self.render_json({'success': False, 'error':'discovery search dispatch failed'})

        componentsEnabled = Components.all()
        componentsEnabled = componentsEnabled.filter_by_app(app)

        componentsEnabledDict = {}
        for component in componentsEnabled:
            hostService = '%s|%s' % (component.host, component.service)
            componentsEnabledDict[hostService] = component.toJsonable()
            componentsEnabledDict[hostService]['found'] = False

        logger.info(str(time.time() - start) + ' - waiting for results...')
        splunk.search.waitForJob(job, maxtime=60)
        logger.info(str(time.time() - start) + ' - results returned ' + str(job.resultCount))

        # if job not done after 60s, timeout & show error page so process is not blocked
        if not job.isDone:
            return self.render_template('/%s:/templates/components_manage_fail.html' % app,
                                        dict(app=app))

        componentsCurrent = []
        jobFeed = job.getFeed(mode='results', count=0)
        if jobFeed:
            componentsCurrent = json.loads(jobFeed)

        # workaround for a 5.0 breaking change of response format of API search/jobs/<search_id>/results
        if isinstance(componentsCurrent, dict):
            componentsCurrent = componentsCurrent['results']

        current_time = self.get_current_timestamp()

        for component in componentsCurrent:
            hostService = '%s|%s' % (component['host'], component['service'])
            if hostService in componentsEnabledDict:
                component['status'] = 'up'
                component.update(componentsEnabledDict[hostService])
                del(component['found'])
                componentsEnabledDict[hostService]['found'] = True
            else:
                component['status'] = 'new'
                component['created_at'] = current_time

        for key in componentsEnabledDict:
            component = componentsEnabledDict[key]
            if component['found'] is False:
                component['status'] = 'down'
                del(component['found'])
                componentsCurrent.append(component)

        componentsCurrent.sort(key=lambda x: x['created_at'], reverse=True)

        if output_mode == 'json':
            return self.render_json(componentsCurrent)
        else:
            return self.render_template('/%s:/templates/components_manage.html' % app,
                                        dict(components=componentsCurrent, app=app))

    @route('/:action=list')
    @expose_page(must_login=True, methods=['GET']) 
    def list(self, action, **kwargs):
        '''Return list of saved components'''

        output = []
        user = cherrypy.session['user']['name'] 
        app = cherrypy.request.path_info.split('/')[3]

        components = Components.all()
        components = components.filter_by_app(app)

        logger.info("number of components found: %d" % len(components))

        for component in components:
            h = component.toJsonable()
            output.append(h)

        return self.render_json(output)

    @route('/:action=save')
    @expose_page(must_login=True, trim_spaces=True, methods=['POST'])
    def save(self, action, **params):
        '''Create/Update posted component '''

        user = cherrypy.session['user']['name'] 
        app = cherrypy.request.path_info.split('/')[3]

        # read POST data of type application/json
        try:
            json_dict = self.parse_json_payload()
        except Exception as e:
            logger.exception(e)
            return self.render_json({'success': False, 'error': str(e)})

        # if 'id' query param provided, request is an update vs a create
        id = params.get('id')
        try:
            if not id:
                component = self.create_component(json_dict, user, app)
            else:
                component = self.update_component(json_dict, user, app, id)
        except Exception as e:
            logger.exception(e)
            return self.render_json({'success': False, 'error': str(e)})

        return self.render_json(component.toJsonable())

    @route('/:action=saveAll')
    @expose_page(must_login=True, trim_spaces=True, methods=['POST'])
    def saveAll(self, action, **params):
        '''Batch create/update/delete of components'''

        user = cherrypy.session['user']['name'] 
        app = cherrypy.request.path_info.split('/')[3]

        # read POST data of type application/json
        try:
            json_list = self.parse_json_payload()
        except Exception as e:
            logger.exception(e)
            return self.render_json({'success': False, 'error': str(e)})

        error = None
        index = 0
        try:
            for json_dict in json_list:
                index += 1
                id = json_dict.get('id')
                if not id:
                    self.create_component(json_dict, user, app, transaction=True)
                else:
                    if json_dict.get('to_delete'):
                        self.delete_component(user, app, id, transaction=True)
                    else:
                        self.update_component(json_dict, user, app, id, transaction=True)
        except Exception as e:
            logger.exception(e)
            error = 'error with item %s (%s)' % (index, str(e))
        
        if error is None:
            return self.render_json({'success': True})
        else:
            # roll back previously created/updated/deleted components
            if not self.rollback_components(user, app):
                logger.error('failed to roll back some components')
            return self.render_json({'success': False, 'error': error})

    @route('/:action=delete')
    @expose_page(must_login=True, trim_spaces=True, methods=['POST']) 
    def delete(self, action, **params):
        '''Delete specific component'''

        user = cherrypy.session['user']['name'] 
        app = cherrypy.request.path_info.split('/')[3]

        # 'id' query param is required
        id = params.get('id')
        if not id:
            return self.render_json({'success': False, 'error': 'component id is required'})
        try:
            self.delete_component(user, app, id)
        except Exception as e:
            logger.exception(e)
            return self.render_json({'success': False, 'error': str(e)})
        
        return self.render_json({'success': True})

    '''
    *****************
    Helper Functions:
    *****************
    '''

    def create_component(self, json_data, user, app, transaction=False):
        '''Create new component using attributes set in json_data'''

        logger.info('create component')
        component = Components(app, user, uuid4())
        component.created_at = self.get_current_timestamp()

        # update component members based on json data
        component.fromJsonable(json_data)
        if not component.passive_save(app):
            raise Exception('error creating component %s: %s' % (component.get_unique_key(), component.errors[0]))
        else:
            # if it's a transaction, save new component in case of a rollback
            if transaction:
                # NOTE: manually set id as create doesn't update model
                component.id = Components.build_id(component.name, app, 'nobody')
                self.components_created.append(component)
            return component

    def update_component(self, json_data, user, app, id, transaction=False):
        '''Update specified component with attributes set in json_data'''

        logger.info('update component')
        try:
            component = Components.get(Components.build_id(id, app, 'nobody'))
        except:
            logger.exception(e)
            return self.create_component(json_data, user, app)

        # if it's a transaction, save component state before update in case of a rollback
        if transaction:
            #backup = Components(app, user, component.name)
            #backup.set_entity_fields(component.entity)
            backup = copy.copy(component)
            self.components_updated.append(backup)

        # update component members based on json data
        component.fromJsonable(json_data)
        if not component.passive_save(app):
            raise Exception('error updating component %s: %s' % (id, component.errors[0]))
        else:
            return component

    def delete_component(self, user, app, id, transaction=False):
        '''Delete specified component'''

        logger.info('delete component')
        try:
            component = Components.get(Components.build_id(id, app, 'nobody'))
        except:
            raise Exception('component \'%s\' not found' % id)

        # if it's a transaction, save component state before deletion in case of a rollback
        if transaction:
            self.components_deleted.append(copy.copy(component))

        if not component.delete():
            raise Exception('failed to delete component \'%s\'' % id)

        return True

    def rollback_components(self, user, app):
        '''Roll back all component changes in current request'''

        logger.info('rollback components')
        logger.debug(self.components_created)
        logger.debug(self.components_updated)
        logger.debug(self.components_deleted)

        result = True
        try:
            # delete created components
            while len(self.components_created) > 0:
                component = self.components_created.pop(0)
                logger.info('rolling back component %s' % component.name)
                if not component.delete():
                    result = False
                    logger.error('rolling back: failed to delete new component %s' % component.name)
            # revert updated components
            while len(self.components_updated) > 0:
                component = self.components_updated.pop(0)
                logger.info('rolling back component %s' % component.name)
                if not component.passive_save(app, True):
                    result = False
                    logger.error('rolling back: failed to revert component %s: %s' % (component.name, component.errors[0]))
            # aad deleted components
            # TODO: ensure component id is same as before
            while len(self.components_deleted) > 0:
                component = self.components_deleted.pop(0)
                logger.info('rolling back component %s' % component.name)
                if not component.passive_save(app, True):
                    result = False
                    logger.error('rolling back: failed to add back component %s: %s' % (component.name, component.errors[0]))
        finally:
            # cleanup in all cases
            del self.components_created[:]
            del self.components_updated[:]
            del self.components_deleted[:]

        return result

    def parse_json_payload(self):
        '''Read request payload and parse it as JSON'''

        body = cherrypy.request.body.read()
        if not body:
            raise Exception('request payload empty')

        logger.debug(body)
        try:
            data = json.loads(body)
        except Exception as e:
            raise Exception('could not parse JSON payload')

        return data

    def get_current_timestamp(self):
        '''Get current unix timestamp'''

        return int(time.time())

    def get_current_datetime(self):
        '''Get current datetime'''

        return datetime.datetime.fromtimestamp(int(time.time()), splunk.util.localTZ)

    def _redirect(self, app, endpoint):
        '''Convenience wrapper to make_url()'''

        return self.make_url(['custom', app, 'hadoopopscomponents', endpoint])
