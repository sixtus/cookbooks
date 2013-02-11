Splunk.Module.HadoopOpsNewsFeed = $.klass(Splunk.Module.DispatchingModule, { 

    initialize: function ($super, container) {
        $super(container);

        this.color_map = {'critical': '', 'high': '', 'info': ''};
        this.count = parseInt(this.getParam('count', '5'));
        this.scoping_field = this.getParam('scoping_field');

        this.$message = $('.message', this.container);
        this.$table = $('.splHadoopOpsNewsFeedTable', this.container);
        this.$tablebody = $('tbody', this.container);
    },

    getResultParams: function ($super) {
        var params = $super();
        params.sid = this.getContext().get('search').job.getSearchId();
        params.count = this.count.toString();
        return params;
    },

    onJobProgress: function (event) {
        this.getResults();
    },

    onJobDone: function (event) {
        this.getResults();
    },

    renderResults: function (data) {
        console.log(data);
        if (data === null || data === undefined) {
            this.$table.hide();
            this.$message.text('Waiting for headlines...'); 
            this.$message.show();
        } else if (data.results !== null && data.results !== undefined) {
            if (data.results.length === 0) {
                this.$table.hide();
                this.$message.text('Nothing news-worthy at the moment...');
                this.$message.show();
            } else {
                this.$message.hide();
                this.$tablebody.children().remove();
                this.$table.show();
                this.addTableRows(data.results);
            }
        } else if (data.error !== null || data.error !== undefined) {
            this.$message.text(data.error);
            this.$table.hide();
            this.$message.show();
        } 
    },
 
    addTableRows: function (results) {
        for (var i = 0; i < Math.min(results.length, this.count); i++) {
            var $new_row = $('<tr>');
            if (i%2 == 0) {
                $new_row.addClass('even');
            }
            if (results[i]['date'] !== null && results[i]['date'] !== undefined) {
                $('<td>').text(results[i]['date'])
                    .addClass('date')
                    .appendTo($new_row);
            }
            if (results[i]['message'] !== null && results[i]['message'] !== undefined) {
                $('<td>').text(results[i]['message'])
                    .addClass('headline')
                    .appendTo($new_row);
            }
            if (results[i][this.scoping_field] !== null && results[i][this.scoping_field] != undefined) {
                var foo = $('<td>').text(results[i][this.scoping_field])
                    .addClass('importance')
                    .appendTo($new_row);
                if (results[i][this.scoping_field] in this.color_map) {
                    foo.addClass(results[i][this.scoping_field]);
                } 
            }
            $new_row.appendTo(this.$tablebody);
        }
    }

});

