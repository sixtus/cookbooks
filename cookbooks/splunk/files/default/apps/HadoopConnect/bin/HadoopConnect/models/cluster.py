from splunk.models.base import SplunkAppObjModel
from splunk.models.field import Field, BoolField, IntField

'''
Provides object mapping for the hdfs clusters
'''


class Cluster(SplunkAppObjModel):

    resource = 'clusters'
    hadoop_home = Field()
    java_home = Field()
    namenode_http_port = IntField()
    authentication_mode = Field()
    authorization_mode = BoolField()
    kerberos_principal = Field()
    kerberos_service_principal = Field()


    def isSecure(self):
        return self.kerberos_principal != None and self.kerberos_principal != ''

