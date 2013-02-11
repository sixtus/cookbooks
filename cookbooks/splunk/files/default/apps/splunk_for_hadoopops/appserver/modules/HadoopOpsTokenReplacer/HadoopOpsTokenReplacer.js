Splunk.Module.HadoopOpsTokenReplacer = $.klass(Splunk.Module, {

    initialize: function($super, container) {
        $super(container);
        this.hide('HIDDEN MODULE KEY');
    },

    getModifiedContext: function($super) {
        var context = this.getContext(),
            form = context.get('form'),
            search = context.get('search'),
            new_search = search.toString(),
            search_tokens = Splunk.util.discoverReplacementTokens(new_search),
            token;
        
        if (form != null && form != undefined && search_tokens.length > 0) {
            for (i=0; i < search_tokens.length; i++) {
                if (form[search_tokens[i]] !== undefined) {
                    token = new RegExp("\\$" + search_tokens[i] + "\\$");
                    var tmp = form[search_tokens[i]],
                        new_str = '( ' + search_tokens[i] + '=',
                        j;
                    if (tmp === null) {
                        new_str = ''; 
                    } else if ($.isArray(tmp) === true) {
                        for (j=0; j < tmp.length; j++) {
                            new_str += '"' + tmp[j] + '"';
                            if (tmp.length !== (j + 1)) {
                                 new_str += ' OR ' + search_tokens[i] + '=';
                            }
                        } 
                        new_str += ' )';
                    } else {
                        new_str +=  '"' + tmp + '" )';
                    }
                    new_search = Splunk.util.replaceTokens(new_search, token, new_str);        
                }
            } 
            search.setBaseSearch(new_search);
            context.set('search', search);
        }
        return context;
    }

});
