Splunk.Module.HadoopOpsMultiSelectInfo = $.klass(Splunk.Module.DispatchingModule, {

    initialize: function($super, container) {
        $super(container);
        this.$table = $('table.splHadoopOpsMultiSelectInfo', this.container);
        this.result_count = 'None'; 
    },

    getFilters: function(form) {
        var output = '';

        for (key in form) {
           if (form[key] !== undefined 
             && form[key].toString() !== 'Undefined'
             && form[key].toString() !== '*') {
               output += key + '=' + form[key].toString() + ' ';
           }
        } 

        return output || 'None';
    },

    updateValues: function() {
        var context = this.getContext(), 
            form = context.get('form') || {};

        this.$table.find('#filter_count').text(this.result_count); 
        this.$table.find('#filters_active').text(this.getFilters(form));
    },

    onJobDone: function() {
        this.result_count = this.getContext().get('search').job.getResultCount();
        this.updateValues(); 
    }

});
