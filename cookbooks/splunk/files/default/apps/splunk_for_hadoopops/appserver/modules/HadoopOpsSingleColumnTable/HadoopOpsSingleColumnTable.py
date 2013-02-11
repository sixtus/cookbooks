import json
import logging
import os
import sys

import cherrypy
import controllers.module as module
import splunk
import splunk.search
import splunk.util
import lib.util as util
from splunk.appserver.mrsparkle.lib import jsonresponse

logger = logging.getLogger('splunk.appserver.controllers.module.HadoopOpsSingleColumnTable')

class HadoopOpsSingleColumnTable(module.ModuleHandler):

    def generateResults(self, host_app, client_app, sid):

        job = splunk.search.JobLite(sid);
        rs = job.getResults('results_preview', '0', '1')
        dataset = rs.results()

        output = self.parse_dataset(dataset) 

        return self.render_json(output)

    def parse_dataset(self, dataset):
        
        output = {'results': [] } 

        for row in dataset:
            for field in row:
                output['results'].append([field, str(row[field])])

        return output

    def render_json(self, response_data, set_mime='text/json'):

        cherrypy.response.headers['Content-Type'] = set_mime

        if isinstance(response_data, jsonresponse.JsonResponse):
            response = response_data.toJson().replace("</", "<\\/")
        else:
            response = json.dumps(response_data).replace("</", "<\\/")

        # Pad with 256 bytes of whitespace for IE security issue. See SPL-34355
        return ' ' * 256  + '\n' + response
