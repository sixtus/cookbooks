import logging

from splunk.models.base import SplunkAppObjModel
from splunk.models.field import Field, BoolField, FloatField

logger = logging.getLogger('splunk.bin.models.components')

'''
Provides object mapping for the hadoopops components endpoint
'''

class Components(SplunkAppObjModel):
    
    resource              = 'hadoopops/hadoop_components'
    host                  = Field()
    service               = Field()
    description           = Field()
    monitored             = BoolField()
    created_at            = FloatField()

    # ordered list of fields that make up the unique composite key of a component
    uniqueCompositeKeyList = ['host', 'service']

    def toJsonable(self):
        '''
        Returns a native structure that represents the current model
        '''
 
        output = {
            'id': self.name
        }
        for k in self.get_mutable_fields():
            output[k] = getattr(self, k)
        
        return output

    def fromJsonable(self, primitive):
        '''
        Parses an object primitive and populates the correct members
        '''

        self.metadata.sharing = 'app'  
        for k in self.get_mutable_fields():
            if primitive.get(k) != None:
                # if incoming property is a dict, then update and not overwrite
                if isinstance(primitive[k], dict) and isinstance(getattr(self, k), dict):
                    getattr(self, k).update(primitive[k])
                else:
                    setattr(self, k, primitive.get(k))

    def get_unique_key(self):
        '''
        Returns component's unique key, i.e. the host-service pair
        '''

        key = '|'.join(map(lambda k: getattr(self, k, ""), self.uniqueCompositeKeyList))
        return key

    def passive_save(self, app="-", skip_validation=False):
        '''
        Override passive save to incorporate possible data validation
        '''

        if not skip_validation:
            if not self._before_save_validate(app):
                return False

        return super(Components, self).passive_save()

    def _before_save_validate(self, app="-"):
        '''
        Returns true if data is valid for saving. Otherwise, error is appended to errors array attribute
        '''

        self.errors = []
        # create vs update
        to_create = not (self.id)
        # build component unique key dict and ensure it does not exist already
        filter_dict = {}
        for field in self.uniqueCompositeKeyList:
            value = getattr(self, field, None)
            if not value:
                self.errors.append('required field \'%s\' is missing' % field)
                return False
            else:
                filter_dict[field] = getattr(self, field)

        dups = self.__class__.all().filter_by_app(app).filter(**filter_dict)
        # return error if:
        #   1. creating new component with a used key, or,
        #   2. updating current component to same key of another component
        if (len(dups) > 0) and (to_create or dups[0].name != self.name):
            self.errors.append('component %s already exists' %  self.get_unique_key())
            return False

        return True
