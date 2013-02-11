/*
*
*/
Splunk.Module.HadoopOpsButtonSearch = $.klass(Splunk.Module.DispatchingModule, {
    initialize: function($super, container) {
        $super(container);
        
        this.searchString = this.getParam('search');
        this.earliestTime = this.getParam('earliest', "-15m");
        this.latestTime = this.getParam('latest', "now");
        this.initLabel = this.getParam("label", "Don't Push Me");
        this.button = $('.HadoopOpsButtonSearch .runSearch', this.container)
            .text(this.initLabel);
        this.label = $('label', this.container).hide();
      
        // load spinner
        $script(Splunk.util.make_url('/modules/HadoopOpsButtonSearch/spin.js'), 'spin');
        $script.ready(['spin'], this.onSpinReady.bind(this) );
    },
  
  /*
   * don't show button until parent loaded 
   */ 
   onJobDone: function() {
       this.button.show();
       this.label.show();
   },

   /*
    * spin init 
    */
    onSpinReady:  function() { 
        // extend jQuery with spin plugin
        $.fn.spinStart = function(opts) {
            this.each(function() {
                var $this = $(this),
                data = $this.data();

                if (data.spinner) {
                    data.spinner.stop();
                    delete data.spinner;
                }
                if (opts !== false) {
                    data.spinner = new Spinner($.extend({color: $this.css('color')}, opts)).spin(this);
                }
            });
        return this;
      };
      
      $.fn.spinStop = function() {
          data = $(this).data();
          if (data.spinner) {
              data.spinner.stop();
              delete data.spinner;
              return this;
          }
      };     
      
      this.button.bind('click', function(event) { 
          this.runSearch(event);
      }.bind(this));
    },
    
   /*
    * run the provided search 
    */
    runSearch: function(event) {
        var context = this.getContext(),
            that = this; 

        event.preventDefault();

        this.button
            .spinStart({
                radius: 4, 
                width: 3,
                length: 4,
                lines: 9
            }); 

	var search =  new Splunk.Search(this.searchString);
	search.dispatchJob(); 
	console.log(search); 


        $.ajax({
            url:  Splunk.util.make_url('/api/search/jobs/'),
            data: {
                search: this.searchString,
                earliest_time: this.earliestTime, 
                latest_time: this.latestTime,
                namespace: Splunk.util.getCurrentApp(),
                status_buckets: 0 
            }, 
            type: 'POST', 
            error: function(a, b, errText){
                console.log(errText); 
                that.label
                    .text(errText)
                    .show();
                that.button.spinStop(); 
            },
            complete: function(data){
                var response;
                if (data != undefined && data!= null 
                    && data.responseText != null && data.responseText != undefined) {
                    response = jQuery.parseJSON(data.responseText);
                }
                if (response.success != undefined && response.success != null
                    && response.success === false) {
                    that.button.spinStop(); 
                    that.label
                        .text('Error: ' + response.messages[0].message)
                        .show();
                } else {
                    that.label
                        .hide()
                        .text('Last Update: ' + new Date().toTimeString());
                    that.button.spinStop(); 
                    that.button.hide();
                    that.passContextToParent(context);
                }
            }
       }); 
       
    }
    
}); 
