Splunk.Module.HadoopOpsServiceMonitoring = $.klass(Splunk.Module.SimpleResultsTable, { 

    initialize: function ($super, container) {
        $super(container);

        this.$button = $('.HadoopOpsServiceMonitoringControls input.manage_components', this.container);
        this.resultsContainer = $('.HadoopOpsServiceMonitoringResults', this.container);
        this.interval = false;
        this.intervalDuration = 10000;
        this.clicked = null;
        this.managePopup = null;
        this.ftrPopup = null;

        // setup event handlers:
        // when manager popup is complete 
        this.container.bind('complete', this.onManagePopupComplete.bind(this));
        // when manager button is clicked
        this.$button.bind('click', this.onButtonClick.bind(this));
        // when any table row is clicked
        $('tr', this.container).bind('click', this.onRowClick.bind(this));

        // check if FTR popup needs to be opened when ftr param is set
        var params = Splunk.util.queryStringToProp(window.location.search);
        if (params && params['ftr'] == 1) {
            this.checkFTR();
        }
    },

    onButtonClick: function(e) {
        e.preventDefault();
        var app = encodeURIComponent(Splunk.util.getCurrentApp()),
            path = Splunk.util.make_url("/custom/" + app + "/hadoopopscomponents/discover"),
            params = {
                callerId: this.moduleId
            };

        path += '?' + Splunk.util.propToQueryString(params)
        this.managePopup = Splunk.Popup.IFramer(path, "");
        return false;
    },

    onRowClick: function() {
        var context = this.getContext(); 
        this.clicked = true; 
        context.set('click', this.moduleId);
        this.pushContextToChildren(context);
    },

    onManagePopupComplete: function(e) {
        if (this.managePopup) {
            this.managePopup.destroyPopup();
        }
    },

    checkFTR: function() {
        var app = encodeURIComponent(Splunk.util.getCurrentApp()),
            path = Splunk.util.make_url("/custom/" + app + "/hadoopopscomponents/list"),
            that = this;

        $.ajax({
            url: path,
            type: 'GET',
            dataType: 'json',
            success: function(data) {
                if (! (data && $.isArray(data) && data.length > 0)) {
                    // no service is configured
                    that.onFTRConfig();
                }
            }
        });
    },

    onFTRConfig: function() {
        var that = this,
            $popup = $('.HadoopOpsServiceMonitoringFTRPopup', this.container);

        $popup.find('a.splButton-secondary').bind('click', function(){
            that.ftrPopup.destroyPopup();
        });
        $popup.find('a.splButton-primary').bind('click', function(){
            that.ftrPopup.destroyPopup();
            that.$button.trigger('click');
        });
        this.ftrPopup = new Splunk.Popup($popup, {
            cloneFlag: false
        });
    },

    onJobDone: function($super, e) {
        $super(e);
        var context = this.getContext();
        if (! this.interval) {
            this.interval = setInterval(this.runSearch.bind(this), this.intervalDuration);
        }
    },

    isReadyForContextPush: function($super) {
        if (this.clicked === null) {
            return Splunk.Module.CANCEL;
        }
        return Splunk.Module.CONTINUE;
    },

    onContextChange: function() {
        this.getResults();
    },

    runSearch: function() {
        this.passContextToParent(this.getContext());
    },

    // override module URL to point to SimpleResultsTable
    getResultURL: function(params) {
        var uri = Splunk.util.make_url('module', 'system', 'Splunk.Module.SimpleResultsTable', 'render');
        params = params || {};
        // set entity_name to return results not events
        params['entity_name'] = 'results';
        uri += '?' + Splunk.util.propToQueryString(params);
        return uri;
    },

    // override simple results table to add grey rows
    renderResults: function($super, htmlFragment, turbo) {
        // do no re-render results if 'waiting for data'
        if ($(htmlFragment).hasClass('resultStatusMessage') && this.interval) {
            //console.log('skipping rendering of \'waiting for data\'');
            return;
        }
        // operate on non-DOM-attached copy for as seemless DOM content update as possible
        var $htmlFragment = $(htmlFragment);
        $htmlFragment
            .find('tbody tr').each(function(idx, evt) {
                if (idx%2 !== 0) { $(evt).addClass('greyRow'); }
            })
            .find('td[field="health"]').children('div.mv').andSelf().filter(function() {
                // support different html based on single-valued vs multi-valued fields
                return $(this).children().length === 0;
            }).each(function() {
                // format & style health column based on health status ratio
                var health = $(this).text(),
                    matches = health.match(/(\d+) \/ (\d+)/),
                    up_nodes = parseInt((matches && matches[1]) || 0, 10),
                    total_nodes = parseInt((matches && matches[2]) || 0, 10);

                var health_tmpl = 
                   "<span "+ ((up_nodes < total_nodes) ? "class=\"nodeDown\">" : ">" ) +
                    up_nodes + "</span> &#47; <span>" + 
                    total_nodes +"</span>";

                 $(this).html(health_tmpl);
            });
        this.resultsContainer.html($htmlFragment);
    },

    // override resetUI so that it doesn't refresh with every job dispatch success callback
    resetUI: function() {
        return true;
    },

    getResultsCompleteHandler: function(xhr, textStatus) {
        //this.resetMetaLastRefreshed();
    },

    // force reset the meta time tag of the layout panel
    resetMetaLastRefreshed: function() {
        $(this.container).closest('.dashboardCell').find('.meta .splLastRefreshed')
            .html('<b>real-time</b>')
            .attr('title', 'refreshed: ' + new Date().toLocaleTimeString());
    }
});
