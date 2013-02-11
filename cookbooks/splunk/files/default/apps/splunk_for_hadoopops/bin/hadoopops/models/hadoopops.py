from splunk.models.base import SplunkAppObjModel
from splunk.models.field import Field, BoolField

'''
Provides object mapping for the hadoopops conf file
'''

class HadoopOps(SplunkAppObjModel):
    
    resource              = 'hadoopops/hadoop_conf'
    has_ignored           = BoolField()
    introspect            = Field()
    disabled              = BoolField()

