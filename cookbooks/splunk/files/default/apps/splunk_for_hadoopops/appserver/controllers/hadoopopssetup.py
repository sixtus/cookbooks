import logging
import os
import sys

import cherrypy

import splunk
import splunk.appserver.mrsparkle.controllers as controllers
import splunk.appserver.mrsparkle.lib.util as util

from splunk.appserver.mrsparkle.lib.decorators import expose_page
from splunk.appserver.mrsparkle.lib.routes import route

dir = os.path.join(util.get_apps_dir(), __file__.split('.')[-2], 'bin')
if not dir in sys.path:
    sys.path.append(dir)
    
from splunk.models.app import App 
from hadoopops.models.hadoopops import HadoopOps 
from hadoopops.models.macro import Macro

logger = logging.getLogger('splunk')

## the macros to be displayed by the setup page 
MACROS = ['hadoop_conf', 'hadoop_os', 'hadoop_daemon_logs', 
          'hadoop_jobtracker_logs', 'hadoop_tasktracker_logs',
          'hadoop_metrics', 'hadoop_topology_script']

class HadoopOpsSetup(controllers.BaseController):
    '''Hadoop Ops Setup Controller'''
 
    @route('/:app/:action=show')
    @expose_page(must_login=True, methods=['GET']) 
    def show(self, app, action, **kwargs):
        ''' shows the hadoop ops setup page '''

        form_content  = {} 
        user = cherrypy.session['user']['name'] 
        host_app = cherrypy.request.path_info.split('/')[3]

        for key in MACROS:
            try:
                form_content[key] = Macro.get(Macro.build_id(key, app, user))
            except:
                form_content[key] = Macro(app, user, key)

        return self.render_template('/%s:/templates/setup_show.html' % host_app, 
                                    dict(form_content=form_content, app=app))

    @route('/:app/:action=success')
    @expose_page(must_login=True, methods=['GET']) 
    def success(self, app, action, **kwargs):
        ''' render the hadoop ops setup success page '''
        
        host_app = cherrypy.request.path_info.split('/')[3]
        ftr = kwargs.get('ftr', 0)

        return self.render_template('/%s:/templates/setup_success.html' \
                                    % host_app,
                                    dict(app=app, ftr=ftr))

    @route('/:app/:action=failure')
    @expose_page(must_login=True, methods=['GET']) 
    def failure(self, app, action, **kwargs):
        ''' render the hadoop ops setup failure page '''
        
        host_app = cherrypy.request.path_info.split('/')[3]

        return self.render_template('/%s:/templates/setup_failure.html' \
                                    % host_app,
                                    dict(app=app))

    @route('/:app/:action=unauthorized')
    @expose_page(must_login=True, methods=['GET']) 
    def unauthorized(self, app, action, **kwargs):
        ''' render the hadoop ops setup unauthorized page '''

        host_app = cherrypy.request.path_info.split('/')[3]
        ftr = kwargs.get('ftr', 0)

        return self.render_template('/%s:/templates/setup_403.html' \
                                    % host_app,
                                    dict(app=app, ftr=ftr))

    @route('/:app/:action=save')
    @expose_page(must_login=True, methods=['POST']) 
    def save(self, app, action, **params):
        ''' save the posted hadoop ops setup content '''

        error_key = None
        form_content = {}
        user = cherrypy.session['user']['name'] 
        host_app = cherrypy.request.path_info.split('/')[3]
        this_app = App.get(App.build_id(app, app, user))
        ftr = 0 if (this_app.is_configured) else 1
        redirect_params = dict(ftr=ftr)

        logger.error(params)
        # pass 1: load all user-supplied values as models
        for k, v in params.iteritems():

            try:
                key = k.split('.')[1]
            except IndexError:
                continue 

            if key and key in MACROS:

                if isinstance(v, list):
                    definition = (' OR ').join(v)
                else:
                    definition = v
                try:
                    form_content[key] = Macro.get(Macro.build_id(key, app, user))
                except:
                    form_content[key] = Macro(app, user, key)
                form_content[key].definition = definition 
                form_content[key].metadata.sharing = 'app'

        # pass 2: try to save(), and if we fail we return the user-supplied values
        for key in form_content.keys():

            try:
                if not form_content[key].passive_save():
                    logger.error('Error saving setup values')
                    return self.render_template('/%s:/templates/setup_show.html' \
                                                % host_app,
                                                dict(name=key, app=app, 
                                                     form_content=form_content))
            except splunk.AuthorizationFailed:
                logger.error('User %s is unauthorized to perform setup on %s' % (user, app))
                raise cherrypy.HTTPRedirect(self._redirect(host_app, app, 'unauthorized', **redirect_params), 303)
            except Exception, ex:
                logger.debug(ex)
                logger.error('Failed to save eventtype %s' % key)
                raise cherrypy.HTTPRedirect(self._redirect(host_app, app, 'failure', **redirect_params), 303)
      
        
        this_app.is_configured = True 
        this_app.share_app()
        this_app.passive_save()

        logger.info('App setup successful')
        raise cherrypy.HTTPRedirect(self._redirect(host_app, app, 'success', **redirect_params), 303)

    def _redirect(self, host_app, app, endpoint, **kwargs):
        ''' convenience wrapper to make_url() '''

        return self.make_url(['custom', host_app, 'hadoopopssetup', app, endpoint], kwargs)

