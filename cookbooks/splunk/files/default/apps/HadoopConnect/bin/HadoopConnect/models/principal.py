from splunk.models.base import SplunkAppObjModel
from splunk.models.field import Field


class Principal(SplunkAppObjModel):
    '''
    Provides object mapping for the principals of kerberos
    '''

    resource = 'krb5principals'
    keytab_path = Field()
