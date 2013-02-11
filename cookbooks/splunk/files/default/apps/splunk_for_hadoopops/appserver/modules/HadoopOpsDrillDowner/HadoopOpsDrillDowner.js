Splunk.Module.HadoopOpsDrillDowner = $.klass(Splunk.Module, {

    initialize: function($super, container) {
        $super(container);
        this.hide('HIDDEN MODULE KEY');
        this.field_list = this.parseFields(this.getParam('fields'));
        this.view_target = this.getParam('view_target');
        this.drill_to_chart = this.getParam('drill_to_chart'); 
    },

    /*
     * on context change, try to populate query string from context.form
     * redirect regardless of presence of query string
     */ 
    onContextChange: function() {
        var context = this.getContext(),
            click = context.get('click'),
            form = context.get('form') || null,
            link = this.view_target,
            search = context.get('search'),
            // grab everything from charting.drilldown. Avoids namespace
            // collisions when drilling from a formated chart
            charting = context.getAll('charting.drilldown') || null, 
            time_range = search.getTimeRange(),
            qsDict = {},
            i, key, val;
       
        if (click !== undefined && click !== null ) {
            if (time_range !== null && time_range !== undefined) {
                if (time_range.getEarliestTimeTerms()) {
                    qsDict["earliest"] = time_range.getEarliestTimeTerms();
                }
                if (time_range.getLatestTimeTerms()) {
                    qsDict["latest"] = time_range.getLatestTimeTerms();
                }
                if (time_range.isAllTime()) {
                    qsDict["earliest"] = 0;
                }
            }

            if (form !== null && typeof form === 'object') {
                if (this.field_list !== null) {
                    for (i = 0; i < this.field_list.length; i++) {
                       if (form.hasOwnProperty(this.field_list[i])) {
                           val = form[this.field_list[i]];
                           if (typeof val === 'string' || typeof val === 'object') {
                               qsDict['form.' + this.field_list[i]] = val; 
                           }
                       }
                    }
                } else {
                    for (key in form) {
                       val = form[key];
                       if (typeof val === 'string' || typeof val === 'object') {
                           qsDict['form.' + key] = val; 
                       }
                    }
                }
           } else {
               // if we have a charting context (From HiddenChartFormatter)
               // and we've passed the drill_to_chart option to the module
               if (typeof charting === "object" &&
                 this.drill_to_chart !== undefined &&
                 this.drill_to_chart !== null) {
                   for (var key in charting) {
                       // looks like chart options in flashtimeline are
                       // prepended with c. namespace
                       qsDict["c." + key] = charting[key];
                   }
               }  
               qsDict['q'] = search.getBaseSearch();
           }

           link += '?' + this.propToQueryString(qsDict);
           this.drillDowner(link); 
        }

    },
 
    /*
     * helper to parse fields param or set to null if unparsable
     */  
    parseFields: function(fields) {
        var output = null;
        if (fields !== undefined && fields !== null) {
            output = fields.split(',');     
            if (typeof output !== 'object' 
              || output.hasOwnProperty('length') === false 
              || output.length < 1) {   
                output = null;
            }
        } 
        return output;
    },

    /*
     * extension of Splunk.util.propToQueryString()
     * required since that one doesn't handle lists
     */ 
    propToQueryString: function(dictionary) {
        var o = [],
            i, prop, val;

        for (prop in dictionary) {
            if ($.isArray(dictionary[prop])) {
                for (i=0; i<dictionary[prop].length; i++) {
                    o.push(encodeURIComponent(prop) + '=' + encodeURIComponent(dictionary[prop][i]));
                }
            } else {
                val = '' + dictionary[prop];
                o.push(encodeURIComponent(prop) + '=' + encodeURIComponent(dictionary[prop]));
            }
        }

        return o.join('&');
    },

    /*
     * Redirects to the link in same or new window depending on whether ctrl is pressed
     */
    drillDowner: function(link) {
        if (link !== undefined && link !== null) {
            window.document.location = link;
        }
    }
});
