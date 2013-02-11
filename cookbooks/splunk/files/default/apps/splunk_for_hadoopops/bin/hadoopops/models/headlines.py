from splunk.models.base import SplunkAppObjModel
from splunk.models.field import Field, BoolField

'''
Provides object mapping for the hadoopops headlines endpoint
'''

class Headlines(SplunkAppObjModel):
    
    resource              = 'hadoopops/hadoop_headlines'
    alert_name            = Field()
    description           = Field()
    label                 = Field()
    message               = Field()
    disabled              = BoolField()


