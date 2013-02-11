if (Splunk && Splunk.Module && Splunk.Module.IFrameInclude) {
    Splunk.Module.IFrameInclude = $.klass(Splunk.Module.IFrameInclude, {
        onLoad: function(event) {
            this.logger.info("IFrameInclude onLoad event fired.");

            this.resize();
            this.iframe.contents().find("body").click(this.resize.bind(this));
            this.iframe.contents().find("select, input").change(this.resize.bind(this));
            // need to fire resize on browser resize (might also need to throttle)
            $(window).resize(this.resize.bind(this));
        },

        resize: function(e) {
                this.logger.info("IFrameInclude resize fired.");

                var height = this.getHeight();
                if(height<1){
                    this.iframe[0].style.height = "auto";
                    this.iframe[0].scrolling = "auto";
                }else{
                    this.iframe[0].style.height = height + this.IFRAME_HEIGHT_FIX + 20 + "px";
                    this.iframe[0].scrolling = "no";
                }

        }

    });
}

$(function(){
    $('.HDFSEntitySelectLister').appendTo('.sel');
});

$(function(){
     // apply this only to home page
     if ( window.location.pathname.lastIndexOf("/home") != window.location.pathname.length - 5)
         return;
    /*
    We only want the chart of indexed data to show in Ace (version 5)
    So lets remove the panel that we don't want and change the row from
    a two col row to a one col row.  CSS should take care of the rest.
    */
    if ($('.splView-home.splVersion-5').length === 0) {
        var $panel = $('.panel_row1_col');
        $panel.children('div:first-child').remove();
        $panel.removeClass('twoColRow').addClass('oneColRow');
    }
});
