// this is where all tooltip help info comes from
var tooltip_content =
{
  'export_name': 'Name of the export job'
, 'export_search': 'Search string that matches the data you want to export'
, 'export_cluster': 'Cluster where to export data'
, 'export_base_path': 'A path which when appended to HDFS URI creates the base export destination'
, 'export_all_new': 'Data arrival date from when to start exporting'
, 'export_parallel_searches': 'Number of parallel searches to use when running the export job'
, 'export_format': 'Format of the exported data'
, 'export_fields': 'Comma delimited list of fields to export'
, 'export_frequency': 'The frequency of the export job execution'
, 'export_partition': 'Choose fields to partition the results by. A field value corresponds to a new path segment.'
, 'export_status' : 'The status of the export job'
, 'export_complete': 'Fraction of the exportable data that has already been exported'
, 'export_load_factor': 'Indicates whether export can keep up with the data rate. Computed as (export duration) / (exported time range)'
, 'export_actions': 'Available actions that can be taken on an export job'
, 'export_maxspan': 'Maximum time range to process during one exporting search (seconds)'
, 'export_minspan': 'Minimum time range to process during one exporting search (seconds)'
, 'export_roll_size': 'Maximum compressed file size to create in HDFS, in MB'

, 'cluster_namenode' : 'Host and ipc port of the cluster\'s Namenode. e.g. namenode.hadoop.example.com:8020'
, 'cluster_hadoop_home': 'Path to Hadoop command line utilities to use when communicating with this cluster'
, 'cluster_java_home': 'Path to Java installation to use when communicating with this cluster'
, 'cluster_secure': 'Is the cluster using Kerberos security'
, 'cluster_actions': 'Available actions that can be taken on a clusters'
, 'cluster_http_port': 'Namenode\'s HTTP port'
, 'cluster_service_principal': 'Kerberos principal that the HDFS service is running as. The value of dfs.namenode.kerberos.principal in core-site.xml'
, 'cluster_default_principal': 'Default Kerberos principal to use when communicating with this cluster'


, 'kerberos_principal' : 'The fully qualified name of the principal. e.g. exporter@domain.example.com'
, 'kerberos_actions' : 'Available actions that can be taken on a Kerberos principal'
, 'kerberos_keytab_file': 'Location in the Splunk server where the keytab file for this principal is located'
};


$(function(){
    // replace place holders
    if(tooltip_content){
        $('.help').each(function(index, value){
           var title = $(this).attr('title'), newTitle = title;
           if(title[0] == '$'){
                      title = title.substr(1);
              if(title in tooltip_content)
              newTitle = tooltip_content[title];
           }
           $(this).attr('title', newTitle);
        });
    }

    $('.help').append('<img class="tooltip" src="/static/app/HadoopConnect/images/question_mark_icon_small_grey.png"/>');
    //if they leave the help icon lets try to cancel the callback to add the tooltip
    $('.tooltip').bind("mouseleave", function(evt){
        var $target = $(evt.target);
        clearTimeout($target.data('tooltip_content_callback'));
    });
    $('.tooltip').bind("mouseenter", function(evt){
        var $target = $(evt.target);

        //In order to ensure they are actually hovering add the help after 50ms
        var callback = setTimeout( function(){
            var $tooltip = $('<span class="tooltip_content"><img src="/static/app/HadoopConnect/images/question_mark_icon_small_grey_whitering.png"/></span>');
            var $text = $target.parent().attr('title');
            $tooltip.append($text);
            $('body').append($tooltip);
            var offset = $target.offset();
            $tooltip.offset({ top: offset.top - 3 , left: offset.left + 3 });
            $('.tooltip_content').bind("mouseleave", function(evt){
                $(this).remove();
            });
        }, 50);
        //We need to keep track of the callback so we can cancel if they leave the help icon
        $target.data('tooltip_content_callback', callback);
    });
});
