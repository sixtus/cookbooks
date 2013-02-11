Splunk.Module.HDFSJobStatus = $.klass(Splunk.Module.JobStatus, {

    HDFS_CREATE_URI: Splunk.util.make_url('custom/HadoopConnect/exportjobs/create'),
    HDFS_CREATE_TITLE: "Create Scheduled HDFS Export",
    initialize: function($super, container){
        $super(container);
        this.scheduleHDFSBtn = $(".schedule-hdfs", this.container);
        this.scheduleHDFSBtn.click(this.onHDFSSchedule.bind(this));
    },
    buildCreateMenu: function($super){
        $super();
        //TODO: EOL This
        this.createMenuItemsDict.push({
            "label" : _("Scheduled HDFS export"),
            "style": "create-report",
            "enabledWhen" : "progress",
            "callback": function(event){
                return this.onHDFSExport(event);
            }.bind(this),
            "showInFilter" : ['buildexport'],
            "enabled" : ["done", "progress"]
        });

        this.updateMenu(self.lastEnabled);
    },
    /**
     * Handle a HDFS export create action. Spawns a popup window from  EAI, w00t!.
     *
     * @param {Object} event A jQuery event.
     */
    onHDFSSchedule: function(event){
        if(this.scheduleHDFSBtn.hasClass(this.DISABLED_CLASS_NAME)){
            return false;
        }
        event.preventDefault();
        var path = this.HDFS_CREATE_URI;
        var title = this.HDFS_CREATE_TITLE;
        Splunk.Popup.WizardHelper(path, title, this.getContext().get('search'), {search: this.getContext().get("search")});
        return false;
    },

    onContextChange: function($super){
        $super();
        this.enableLinks(this.scheduleHDFSBtn);
    },
    onBeforeJobDispatch: function($super){
        $super();
        this.disableLinks(this.scheduleHDFSBtn);
    },
    onJobProgress: function($super){
        $super();
        this.enableLinks(this.scheduleHDFSBtn);
    }
});
