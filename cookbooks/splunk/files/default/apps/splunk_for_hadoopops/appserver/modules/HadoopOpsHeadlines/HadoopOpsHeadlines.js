Splunk.Module.HadoopOpsHeadlines = $.klass(Splunk.Module, { 

    initialize: function ($super, container) {
        $super(container);

        this.count = parseInt(this.getParam('count') || '10');
        this.drilldown_view = this.getParam('drilldown_view');

        this.$button = $('input#manage_headlines');
        this.$message = $('.message', this.container);
        this.$table = $('.splHadoopOpsHeadlinesTable', this.container);
        this.$tablebody = $('tbody', this.container);
        this.interval = null;
        this.popup = null;
 
        this.$button.bind('click', this.onButtonClick.bind(this));

    },

    onButtonClick: function(e) {
        var options = {},
            app = encodeURIComponent(Splunk.util.getCurrentApp()),
            path = Splunk.util.make_url("/custom/" + app + "/hadoopopsheadlines/" + app + "/manage");

        e.preventDefault();
        this.popup = Splunk.Popup.IFramer(path, "", options);
    },

    onContextChange: function() {
        var earliest = this.getContext()
                         .get('search')
                           .getTimeRange()
                             .getEarliestTimeTerms();
        this.earliest = earliest;
        this.interval = setInterval(this.getResults.bind(this), 30000);
        this.getResults();
    },

    // override
    getResultURL: function(params) {
        var app = Splunk.util.getCurrentApp(),
            uri = Splunk.util.make_url('custom', app, 'hadoopopsheadlines', app, 'list');

        params = params || {};
        params['count'] = this.count;
        if (this.earliest !== null) {
            params['earliest'] = this.earliest;
        }
        params['4IE'] = Math.random();
        uri += '?' + Splunk.util.propToQueryString(params);
        return uri;
    },

    renderResults: function (data) {
        if (data === null || data === undefined) {
            this.$table.hide();
            this.$message.text('Waiting for headlines...'); 
            this.$message.show();
        } else if (data.headlines !== null && data.headlines !== undefined) {
            if (data.headlines.length === 0) {
                this.$table.hide();
                this.$message.text('Nothing news-worthy at the moment...');
                this.$message.show();
            } else {
                this.$message.hide();
                this.$tablebody.children().remove();
                this.$table.show();
                this.addTableRows(data.headlines);
            }
        } else if (data.error !== null || data.error !== undefined) {
            this.$message.text(data.error);
            this.$table.hide();
            this.$message.show();
        } 
        this.$button.show();
    },

    addTableRows: function (results) {
        var app = Splunk.util.getCurrentApp(),
            uri = Splunk.util.make_url('app', app, this.drilldown_view),
            $new_row, param, result;

        for (var i = 0; i < Math.min(results.length, this.count); i++) {
            $new_row = $('<tr>');
            result = results[i];
            if (result['message'] !== null && result['message'] !== undefined) {
                $('<td>').text(result['message'])
                    .addClass('headline')
                    .addClass('severity' + result['severity'].toString())
                    .appendTo($new_row);
            }
            if (result['timesince'] !== null && result['timesince'] !== undefined) {
                $('<td>').text(result['timesince'] + ' ago')
                    .addClass('date')
                    .appendTo($new_row);
            }
            $new_row.children().bind("click", function() { 
                param = {'s': result['job_id']};
                uri += '?' + Splunk.util.propToQueryString({'sid': result['job_id']}); 
                window.location = uri;
            }).css('cursor','pointer');
            $new_row.appendTo(this.$tablebody);
        }
    }

});
