Splunk.Module.HadoopOpsSingleRowTable = $.klass(Splunk.Module.DispatchingModule, {

    initialize: function($super, container) {
        $super(container);
        this.bgcolor = this.getParam('bgcolor', '#EEE9E9');
        this.drilldown_key = this.getParam('drilldown_key');
        this.drilldown_map = $.extend({}, this.drilldown_map);
        this.parseDrilldownMap(this.getParam('drilldown_map'));
        this.drilldown_val = this.getParam('drilldown_val');
        this.label = this.getParam('label');
        this.islast = this.getParam('islast', false);
        this.notop = this.getParam('notop', false);
        this.static_value = this.applyTransform(this.getParam('static_value'));
        this.transform = this.getParam('drilldown_transform') || null;
        $('.label span', this.container).text(this.label);
        $('.HadoopOpsSingleRowTableInner', this.container).css('background-color', this.bgcolor);
        if (Splunk.util.normalizeBoolean(this.islast) === true) {
            $('.HadoopOpsSingleRowTableInner', this.container).addClass('islast');
        }
        if (Splunk.util.normalizeBoolean(this.notop) === true) {
            $('.HadoopOpsSingleRowTableInner', this.container).addClass('notop');
        }
        this.$message = $('.message', this.container);
        this.$table = $('table.splHadoopOpsSingleRowTable', this.container);
    },

    applyTransform: function(value) {
        if (this.transform !== undefined && this.transform !== null) { 
            switch (this.transform) {
                case 'all_upper':
                    return value.toUpperCase();
                case 'all_lower':
                    return value.toLowerCase();
                default:
                    return value;
            }
        }
    },

    destroyCells: function() {
        this.$table.find('.generated').remove(); 
        this.$table.find('.generated').remove(); 
    },
 
    parseDrilldownMap: function(value) {
        var i, map, value_list, drilldown_map = {};
        if (value !== undefined && value !== null) {
            value_list = value.split(',');
            if ($.isArray(value_list) === true && value_list.length > 0) {
               for (i = 0; i < value_list.length; i++) {
                   map = value_list[i].split('=');
                   if ($.isArray(map) === true && map.length === 2 
                       && map[0] !== undefined && map[0] !== null ) {
                       drilldown_map[map[0]] = map[1];
                   } 
               } 
            }
            this.drilldown_map = $.extend({}, this.drilldown_map, drilldown_map);
        }
    },

    genElements: function(table_arr, loc) {
        var $elm;
        for (var i=0; i<table_arr.length; i++) {
            $elm = $('<td>')
                      .text(table_arr[i])
                      .addClass('generated');
            if (loc === 'tbody') {
                $elm.bind("click", this.onClick.bind(this))
                    .css('cursor','pointer');
            }
            $elm.appendTo(this.$table.children(loc).children('tr')); 
        }
    },

    onClick: function(event) { 
        var context = this.getContext(),
            form = context.get('form') || {};
        if (this.drilldown_val === 'static') {
            form[this.drilldown_key] = this.static_value;
        } else {
            form[this.drilldown_key] = this.getDrilldownVal(event); 
        }
        context.set('form', form);
        context.set('click', this.moduleId);
        this.pushContextToChildren(context);  
    }, 

    getResultParams: function($super) {
        var params = $super,
            sid = this.getContext().get('search').job.getSearchId();
        params.sid = sid;
        return params;
    },

    onBeforeJobDispatched: function(search) {
        search.setMinimumStatusBuckets(300);
    },
    
    onContextChange: function() {
        this.destroyCells();
        this.$message.show();
    },

    onJobProgress: function(event) {
        this.getResults();
    },

    onJobDone: function(event) {
        this.getResults();
    },

    parseData: function(results) {
        var table_obj = {'header': [], 'body': []};
        for (var i=0; i<results.length; i++) {
            for (first in results[i]) {
                table_obj['header'].push(first);
                table_obj['body'].push(results[i][first]);
            }
        }
        return table_obj;
    },

    renderResults: function(data) {
        if (!(data) || data === undefined || data === null 
            || data.results === null || data.results === undefined) {
            this.$message.show();
        } else {
            this.destroyCells();
            this.$message.hide();
            this.renderTable(this.parseData(data.results));
        }
    },

    renderTable: function(table_obj) {
        this.genElements(table_obj['header'], 'thead');
        this.genElements(table_obj['body'], 'tbody');
    },
    
    getDrilldownVal: function(event) {
        var $el = $(event.target), 
            idx = $el.parent()
                      .children()
                      .index(event.target) + 1,
            header = this.$table.find("thead tr td:nth-child(" + idx + ")").text(),
            row = $el.parent().children(":first-child").text(),
            val = $el.text(), 
            drilldown_val;
        switch (this.drilldown_val) {
            case 'header':
                drilldown_val = header;
                break;
            case 'label':
                drilldown_val = this.label;
                break;
            case 'value':
                drilldown_val = val;
                break;
            default:
                drilldown_val = header;
        }
        if (drilldown_val in this.drilldown_map) {
            drilldown_val = this.drilldown_map[drilldown_val];
        }
        return this.applyTransform(drilldown_val);
    }

});
