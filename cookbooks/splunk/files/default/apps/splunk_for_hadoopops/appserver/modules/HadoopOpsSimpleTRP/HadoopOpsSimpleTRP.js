Splunk.Module.HadoopOpsSimpleTRP = $.klass(Splunk.Module, {

    initialize: function($super, container) {
        $super(container);
        this.earliest = $('.selected', container).attr('id');
        this.latest = this.getLatest(this.earliest);
        $('.SimpleTimeRange', container).bind('click', function(event) { 
            this.onClick(event);
        }.bind(this)); 
    },

    getLatest: function(earliest) {
        var latest;
        if (earliest.indexOf('rt') !== -1) {
            latest = 'rt';
        } else {
            latest = 'now';
        }
        return latest;
    },

    onClick: function(event) {
        event.preventDefault();
        $(this.container).find('input.selected').removeClass('selected');
        $(event.target).addClass('selected');
        this.earliest = event.target.id;
        this.latest = this.getLatest(this.earliest);
        this.pushContextToChildren();
    },

    onContextChange: function() {
        this.pushContextToChildren();
    },

    getModifiedContext: function() {
        var context = this.getContext(),
            search = context.get('search'),
            range;
            
        if (this.earliest == 'all') {
            range = new Splunk.TimeRange();
        } else {
            range = new Splunk.TimeRange(this.earliest, this.latest);
        }

        search.setTimeRange(range);
        context.set('search', search);
        return context;
    }
}); 