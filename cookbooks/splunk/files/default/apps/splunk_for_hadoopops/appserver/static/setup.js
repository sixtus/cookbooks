/*
   @author      araitz
   @name        setup.js
   @description client-side for hadoop ops app setup

*/
// default window feature for preview windows
DEFAULT_WINDOW_FEATURES = 'status=1,toolbar=1,location=1,menubar=1,resizable=1,scrollbars=1,directories=1';
// handler for 'Add New' button click
function onAddClick(event){
    var $target = $(event.target),
        $parent = $target.closest('dd'),
        $container = $target.closest('.belowInput').prev(),
        $new_input;

    event.preventDefault();
    $container.children().removeClass('singleRow');
    $new_input = $container.clone(true, true);
    $container.after($new_input);
}

// handler for 'Remove' button click
function onRemoveClick(event){
    var $parent = $(event.target).parent(),
        $container = $(event.target).closest('dd');

    // 3 or less means that there will only be one element left
    if ($container.children().length < 4) {
        $container.find('span.remove-text')
            .addClass('singleRow');
    }   
    // remove the element itself
    $parent.remove();
}

// handler for 'Preview' button click
function onPreviewClick(event){
    var $macros = $(event.target).closest('dd').find('.dynamic-text'),
        path = document.location.pathname.split('/'),
        app = path[path.length-2] || 'splunk_for_hadoopops',
        search, search_string,
        values = [];

    // create list of search strings for preview search
    $macros.each(function() {
        if ($.trim($(this).val()) !== '') {
            values.push($.trim($(this).val()));    
        }
    });

    // generate aggregate search string 
    if (values.length > 0) {
        search_string = searchGenerator(values);  
    }

    // if we have a search string, dispatch the search in a new window
    if (search_string !== undefined && search_string !== null && search_string.length > 0 && search_string !== '*') {
	search_string = search_string.concat(' | head 20');
        search = new Splunk.Search(search_string);
        search.sendToView('hadoopops_flashtimeline', {}, false, true, 
                          {'windowFeatures': DEFAULT_WINDOW_FEATURES}, app);
    } 
    // NOOP
}

// returns a formatted search string
function searchGenerator(values) {
    var i,
        output = null, 
        outputList = [];

    for (i=0; i<values.length; i++) {
        if (values[i] && values[i] !== undefined && values[i] !== null) {
            outputList.push(values[i]);
        } 
    }
    if (outputList.length > 0 ) {
        output = outputList.join(' OR ');
    }
    return output; 
}

function getTooltipText(id) {
    switch(id){
        case "tip_hadoop_conf":
            return "Specify where hadoop configuration data has been indexed using one or more search strings";
        case "tip_hadoop_daemon_logs":
            return "Specify where hadoop daemon logs other than jobtracker or tasktracker have been indexed using one or more search strings";
        case "tip_hadoop_jobtracker_logs":
            return "Specify where hadoop jobtracker logs have been indexed using one or more search strings";
        case "tip_hadoop_tasktracker_logs":
            return "Specify where hadoop tasktracker logs have been indexed using one or more search strings";
        case "tip_hadoop_metrics":
            return "Specify where hadoop metrics data has been indexed using one or more search strings";
        case "tip_hadoop_os":
            return "Specify where hadoop node OS data has been indexed using one or more search strings";
        case "tip_hadoop_topology_script":
            return "Specify the script to execute to get the rackid of a cluster host";

    }
}

$(document).ready(function() {

    // bind 'Add New' button click to the onAddClick() handler
    $('.add-text').bind('click', function(event) {
        event.preventDefault();
        onAddClick(event);
    });

    // bind 'Remove' button click to the onRemoveClick() handler
    $('.remove-text').bind('click', function(event) {
        event.preventDefault();
        onRemoveClick(event);
    });

    // bind 'Preview' button click to the onPreviewClick() handler
    $('.preview').bind('click', function (event) {
        event.preventDefault();
        onPreviewClick(event);
    });

});

