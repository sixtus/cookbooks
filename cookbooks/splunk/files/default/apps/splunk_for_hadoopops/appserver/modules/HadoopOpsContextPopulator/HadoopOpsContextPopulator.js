Splunk.Module.HadoopOpsContextPopulator = $.klass(Splunk.Module.DispatchingModule, {

    initialize: function($super, container) {
        $super(container);
        this.hide('HIDDEN MODULE KEY');
        this.internal_search = null;
        this.options = null;
        this.filter_info = null
        this.prev_search = null;
    },

    /*
     * add internal sid to getResults() request
     */ 
    getResultParams: function($super) {
        var params = $super();
        params['sid'] = this.getContext().get('search').job.getSearchId();
        return params;
    },

    /*
     * if the search string and time range are the same as last, return false
     */ 
    needsGetResults: function(search) {
        var ret = true;
        if (search.getTimeRange().equalToRange(this.prev_search.getTimeRange())) {
            if (search.toString() === this.prev_search.toString()) {
                ret = false; 
            } 
        } 
        return ret;
    },

    /*
     * when internal job is done, call the module controller 
     */ 
    onJobDone: function() {
        var search = this.getContext().get('search');
        if (this.prev_search === null || this.needsGetResults(search)) {
            this.getResults();
        }
        this.prev_search = search;
    },

    /*
     * insert data from controller response in to options
     */ 
    renderResults: function(data) {
        var context = this.getContext();
        this.options = data;
        context.set('options', this.options);
        this.passContextToParent(context);
        this.internal_search = null;
    }

});
