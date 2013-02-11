Splunk.namespace("Module");
Splunk.Module.HadoopOpsFTR= $.klass(Splunk.Module, {

    initialize: function($super, container) {
        $super(container);
        this.logger = Splunk.Logger.getLogger("hadoop_ops_ftr.js");
        this.messenger = Splunk.Messenger.System.getInstance();
        this.popupDiv = $('.ftrPopup', this.container).get(0);
        $('a.splButton-secondary', this.container).bind('click', this.setIgnored.bind(this));
        this.getResults();
    },

    renderResults: function(response, turbo) {
        if ((response.has_ignored && response.has_ignored===true) 
                || (response.is_configured && response.is_configured===true)) {
            return true;
        } else {
            if (response.is_admin !== undefined && response.is_admin===false) {
                $("p.AdminConfig", this.container).hide();
                $("p.nonAdminConfig", this.container).show();
                $("a.splButton-primary", this.container).hide();
                $("a.splButton-secondary", this.container).css('float', 'right');
            }
            this.popup = new Splunk.Popup(this.popupDiv, {
                cloneFlag: false,
                pclass: 'configPopup'
           });
        }
    },

    setIgnored: function(event) {
        var params = this.getResultParams();
        if (!params.hasOwnProperty('client_app')) {
            params['client_app'] = Splunk.util.getCurrentApp();
        }
        params['set_ignore'] = true;
        var xhr = $.ajax({
            type:'GET',
            url: Splunk.util.make_url('module', 
                Splunk.util.getConfigValue('SYSTEM_NAMESPACE'), 
                this.moduleType, 
                'render?' + Splunk.util.propToQueryString(params)
            ),
            beforeSend: function(xhr) {
                xhr.setRequestHeader('X-Splunk-Module', this.moduleType);
            }, 
            success: function() {
                return true;
            }.bind(this),
            error: function() {
                this.logger.error(_('Unable to set ignored flag')); 
            }.bind(this),
            complete: function() {
                this.popup.destroyPopup(); 
            }.bind(this)
        });

    }
});
