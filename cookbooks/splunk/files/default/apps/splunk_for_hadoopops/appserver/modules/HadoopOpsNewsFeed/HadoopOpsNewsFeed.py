import datetime
import json
import logging
import math
import os
import sys

import cherrypy

import splunk.search
import splunk.util
import controllers.module as module
from splunk.appserver.mrsparkle.lib import i18n, jsonresponse, util

logger = logging.getLogger('splunk.modules.hadoopops_news_feed')

class HadoopOpsNewsFeed(module.ModuleHandler):
    
    def generateResults(self, host_app, client_app, sid, offset=0, count=5, 
                        post_process=None, entity_name='results_preview', **args): 

        output = {'results': []}

        try:
            job = splunk.search.getJob(sid)
        except Exception, ex:
            output['errors'] = "Splunk could not retrieve events for this search."
            logger.exception(ex)

        if post_process:
            job.setFetchOption(search=post_process)

        job.setFetchOption(
            time_format = cherrypy.config.get('DISPATCH_TIME_FORMAT'),
            output_time_format='%b %d %T'
        )
        
        count = int(count)
        offset = int(offset)
        
        if entity_name in ["results", "results_preview"]:
            field_list = job.results.fieldOrder
            count_constraint = job.resultCount
        else:
            count_constraint = job.eventAvailableCount

        count_constraint = int(count_constraint)
        offset_start = offset

        if offset < 0:
            if count == 0:
                offset_end = 0
            elif count < abs(offset) and count == count_constraint:
                offset_start = -count
                offset_end = None
            else:
                offset_end = min(0, offset + count)
        else:
            if count == 0:
                offset_end = count_constraint
            else:
                offset_end = min(count_constraint, offset + count)
        
        if entity_name in ['results', 'results_preview']:
            events = job.results[offset_start:offset_end]
        else:
            events = job.events[offset_start:offset_end]

        for i, event in enumerate(events):
            output['results'].append(
                {'date': str(event['date']),
                 'message': str(event.get('message')),
                 'importance': str(event.get('importance'))
            })

        return self.render_json(output) 

    def render_json(self, response_data, set_mime='text/json'):
        cherrypy.response.headers['Content-Type'] = set_mime
    
        if isinstance(response_data, jsonresponse.JsonResponse):
            response = response_data.toJson().replace("</", "<\\/")
        else:
            response = json.dumps(response_data).replace("</", "<\\/")

        # Pad with 256 bytes of whitespace for IE security issue. See SPL-34355
        return ' ' * 256  + '\n' + response

