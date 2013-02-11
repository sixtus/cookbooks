Splunk.Module.HadoopOpsDynamicContentSample = $.klass(Splunk.Module, {

    initialize: function($super, container) {
        $super(container);
        this.$dynamic_text = $('.dynamic_text', this.container);
        this.hide('HIDE UNTIL DATA');
        this.reveal_on_progress = Splunk.util.normalizeBoolean(this.getParam('reveal_on_progress'));
    },

    onContextChange: function() {
        var context = this.getContext(),
            search = context.get('search');
        if (search.isJobDispatched() || search.job.isDone) {
            this.show('HIDE UNTIL DATA');
            this.$dynamic_text.show();
        } else {
            this.hide('HIDE UNTIL DATA');
            this.$dynamic_text.hide();
        }
    }

});