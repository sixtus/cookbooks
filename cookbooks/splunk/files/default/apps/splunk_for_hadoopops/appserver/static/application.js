switch (Splunk.util.getCurrentView()) {

    case 'jobs_running': case 'job_history': 

        // deal with special case drilldowns for job views
        if (Splunk.Module.SimpleResultsTable) {

            Splunk.Module.SimpleResultsTable = $.klass(Splunk.Module.SimpleResultsTable, { 

                initialize: function($super, container) {
                    $super(container);
                    this.drilldown_container = $('.DrilldownRow');
                    this.offset = this.getOffset();
                    this.text = null;
                    $('tr', this.container).bind('click', this.onRowClick.bind(this));
                },

                getOffset: function() {
                    if (Splunk.util.getCurrentView() === 'jobs_running') {
                        return 55;
                    } else {
                        return 35;
                    }
                },

                onContextChange: function($super) {
                    this.hideAll();
                    $super();
                },

                getModifiedContext: function() {
                    var context = this.getContext(),
                        click = context.get('click') || {},
                        form = context.get('form'),
                        search = context.get('search'),
                        time_range = search.getTimeRange();

                    
                    if (this.text !== null) {
                        search.abandonJob();
                        form['earliest'] = time_range.getEarliestTimeTerms();
                        form['latest'] = time_range.getLatestTimeTerms();
                        form['job_id'] = this.text;
                        click['name'] = this.moduleId;
                        context.set('click', click);
                        context.set('form', form);
                        context.set('search', search);
                    }
                
                    return context;
                },

                hideAll: function() {
                    this.drilldown_container.hide();
                    this.hideDescendants(this.DRILLDOWN_VISIBILITY_KEY + '_' + this.moduleId);
                    this.setDrilldownTop(null);
                },

                isReadyForContextPush: function($super) {
                    if (this.text === null) {
                        return Splunk.Module.CANCEL;
                    }
                    return Splunk.Module.CONTINUE;
                },

                onRowClick: function($super, e) {
	            var $target = $(e.target),
                        $parent = $target.parent(),
                        $g_parent = $parent.parent(),
                        $sibling = $parent.siblings('.expanded'),
			            text = $parent.children('td[field="job_id"]').text();

                    e.preventDefault();
                    if (e.target.nodeName !== 'TD') {
                        return $super(e);
                    }
                    this.hideAll();
                    this.text = text;

                    $parent.toggleClass('expanded')
                      .children(':first-child')
                        .toggleClass('arrowOpen');

                    $sibling.toggleClass('expanded')
                      .children(':first-child')
                        .toggleClass('arrowOpen');

                    if ($parent.hasClass('expanded') === true) {
                        this.showAll($target.offset()['top'] + this.offset);
                    } 
                    this.pushContextToChildren();
                },

                renderResults: function($super, htmlFragment) {
                    var results;
                    $super(htmlFragment);
                    results = $('tr', this.container);
                    if (results.length == 2) {
                        results.eq(1).children(':first-child').trigger('click'); 
                    }
                },

                setDrilldownTop: function(pos) {
                    if (pos !== null && pos !== undefined) {
                        this.drilldown_container.css('position', 'absolute')
                            .css('top', pos);
                    } else {
                        this.drilldown_container.css('position', 'relative')
                            .css('top', '0');
                    }
                },

                showAll: function(pos) {
                    this.setDrilldownTop(pos);
                    this.drilldown_container.show();
                    this.showDescendants(this.DRILLDOWN_VISIBILITY_KEY + '_' + this.moduleId);
                }

            });
        }
        break;

    case 'nodes':

        if (Splunk.Module.SimpleResultsTable) {

            Splunk.Module.SimpleResultsTable = $.klass(Splunk.Module.SimpleResultsTable, {

                DEFAULT_SPARKLINE_SETTINGS: {
                    type: 'line',
                    lineColor: '#6696c4',
                    lineWidth: '1.5',
                    width: '100',
                    highlightSpotColor: null,
                    minSpotColor: null,
                    maxSpotColor: null,
                    spotColor: null,
                    fillColor: null
                }

            });
        }

        if (Splunk.Module.StaticContentSample) {
            
            Splunk.Module.StaticContentSample = $.klass(Splunk.Module.StaticContentSample, {

                onContextChange: function($super) {
                    var context = this.getContext(),
                        click = context.get('click') || null,
                        form = context.get('form') || null,
                        prev = this.container.prev(),
                        node_indicator = d3.select(prev.get(0)).select("svg");
 
                    if (click !== undefined && click !== null) {
                        this.hide('CLICK KEY');
                        if (form !== null 
                          && form['host'] !== null
                          && form['host'] !== undefined) {
                            node_indicator.select("g").select("text").text(form['host']);
                            node_indicator.select("g").select("title").text(form['host']);
                        }
                        $(prev).show();
                        this.showDescendants('CLICK KEY');
                    } else {
                        this.hideDescendants('CLICK KEY');
                        $(prev).hide();
                        node_indicator.select("g").select("text").text("---");
                        node_indicator.select("g").select("title").text("---");
                        this.show('CLICK KEY');
                    }
                }

            });
        }

        // position the detail panel at top of the visible area
        $(window).scroll(function() {
            var win_top = parseInt($(window).scrollTop()) + 70,
                max_top = parseInt($(".NodesContainer").height()) - 485,
                $detail = $(".NodeDetail"),
                t = Math.min(Math.max(win_top, 250), max_top);
            $detail.css("top", t + 'px');
        });

        // the module calls resize on its own container
        // this is where we hook in to resize the main container
        $(".HadoopOpsNodes").bind("resize", function() { 
            $(".NodesContainer").height($(this).height() * 1.4);
        });

        // keep things looking relatively neat 
        $(window).bind("resize", function() {
            var w = $(window).width(),
                tmp;

            // quit resizing at 1175px 
            if (w > 1174) {
                $(".NodesContainer").css("width", "97%")
                    .css("margin-left", "auto");
                $(".NodeStatus").css("width", parseInt(w-80));
                $(".NodeDetail").css("left", w - 350).show();
                $(".NodeControl").css("min-width", w - 415).show();
            } else {
                $(".NodesContainer").css("width", "1150");
                $(".NodeStatus").css("width", 1175);
                $(".NodeDetail").css("left", 850).show();
                $(".NodeControl").css("min-width", 800).show();
            }
        });
        break;

    case 'home':

        // ensure consistent style between Splunk 4.x and 5.x 
        if ($('body').hasClass('splVersion-4') === true) {
            $('.SingleValue .singleResult').css('vertical-align', '-4px');
        }
     
        // keep the 'refreshed' meta information consistent on headlines panel
        $(document).ready(function() {
            var $meta = $('.panel_row2_col').children(':first-child').find('.meta'),
                $span = $('<span>').addClass('splLastRefreshed'),
                $belm = $('<b>').text('real-time');
            $span.append($belm);
            $meta.append($span);
        });
    
        // make the look consistent whether displaying 2 or 3 rows in the activities panel
        if (Splunk.Module.HadoopOpsSingleRowTable) { 
               
            Splunk.Module.HadoopOpsSingleRowTable = $.klass(Splunk.Module.HadoopOpsSingleRowTable, {
                
                onContextChange: function($super) {
                    if (this.moduleId==="HadoopOpsSingleRowTable_2_2_0") {
                        if (this.getContext().get("search").getTimeRange().isRealTime()) {
                            this.hide('TOGGLE VISIBILITY'); 
                            this.container.parent()
                                .find('.HadoopOpsSingleRowTable:visible:last')
                                  .find('.HadoopOpsSingleRowTableInner').addClass('islast');
                            $(this.container).closest('.HadoopOpsSingleRowTable')
                        } else { 
                            this.container.parent()
                                .find('.HadoopOpsSingleRowTable:visible:last')
                                  .find('.HadoopOpsSingleRowTableInner').removeClass('islast');
                            this.show('TOGGLE VISIBILITY'); 
 		        }
                    } 
                    $super(); 
                }
	       }); 
        }

        // wire up hidden search to listen for context changes pushed upwards
        // in order to dispatch its search again
        if (Splunk.Module.HiddenSearch) {

            Splunk.Module.HiddenSearch = $.klass(Splunk.Module.HiddenSearch, {

                applyContext: function(context) {
                    var search = context.get('search');
                    search.job.cancel();
                    search.abandonJob();
                    this.pushContextToChildren();
                }

            });
        }
        break;
}

// NoelGuage shim
if (Splunk.Module.JSChart) {

    Splunk.Module.JSChart = $.klass(Splunk.Module.JSChart, {

        initialize: function($super, container) {
            $super(container);
            this.clicked = null;
        },

        draw: function(updateCount) {
            // if dependencies are not loaded yet, defer the draw the their on-ready callback
            if(!this.chartingLibLoaded) {
                this.hasPendingDraw = true;
                return;
            }
            var i, newFieldList,
                fieldInfo = Splunk.JSCharting.extractFieldInfo(this.response),
                data = this.getChartReadyData(this.response, fieldInfo, this.properties),
                drawCallback = function(chartObject) {
                    this.redrawNeeded = false;
                    this.onDataUpdated({updateCount: updateCount});
                    this.updateGlobalReference(chartObject);
                }.bind(this);

            this.destroyChart();

         
            // hook in if 'noelGauge' is specified
            if (this.properties.chart == 'noelGauge') {

                $(this.chartContainer).bind('click', this.onChartClicked.bind(this))
                    .css('cursor','pointer'); 

                // I can't find another place where the JSCharting namespace is available
                Splunk.JSCharting.NoelGauge = $.klass(Splunk.JSCharting.AbstractGauge, {

                    typeName: 'noelGauge-chart',

                    initialize: function($super, container) {
                        $super(container);
                        this.arcStart = (2.1+Math.PI/180);
                        this.arcFinish = (7.3+Math.PI/180);
                        this.arcDiff = this.arcFinish - this.arcStart;
                        this.container = $(container);
                        this.chart = null;
                        this.primaryAxisTitle = null;
                        this.gaugeUnits = null;
                        this.showMajorTicks = false;
                        this.showMinorTicks = false;
                        this.maxValueLength = 4;
                        this.maxValueDecimalLength = 2;
                    },      

                    applyPropertyByName: function($super, key, value, properties) {
                        $super(key, value, properties);

                        switch(key) {
                            case 'primaryAxisTitle.text':
                                this.primaryAxisTitle = value;
                                break;
                            case 'units':
                                this.gaugeUnits = value;
                                break;
                            case 'chart.usePercentageRange':
                                this.usePercentageRange = (value === 'true');
                                break;
                            case 'chart.usePercentageValue':
                                this.usePercentageValue = (value === 'true');
                                break;
                        }
                    }, 

                    drawFill: function(value) {
                        var renderer = this.renderer;
                        if (this.elements.fill) {
                            this.elements.fill.destroy();
                        }
                        this.elements.fill = this.renderer.arc(
                            renderer.width/2,
                            renderer.height/2,
                            renderer.width/3,
                            renderer.width/3 - 20,
                            this.arcStart,
                            this.getFill(value)
                        ).attr({
                            fill: this.getFillColor(value)
                        }).add();
                    },

                    formatValue: function($super, value) {
                        if (value === 0 ) {
                            return '---';
                        } else { 
                            return $super(value);
                        }
                    },

                    getFill: function(value) {
                        var output;
                        if (this.usePercentageValue) {
                            output = Math.min(this.arcStart + (this.arcDiff * value/100), this.arcFinish);
                        } else {
                            output = Math.min(this.arcStart + (this.arcDiff*(value/this.ranges[this.ranges.length-1])), this.arcFinish);
                        }
                        return output;
                    },

                    getFillColor: function(val) {
                        var i;
                        for(i = 0; i < this.ranges.length - 2; i++) {
                            if(val < this.ranges[i + 1]) {
                                break;
                            }
                        }
                        return this.getColorByIndex(i);
                    },

                    getTextXOffset: function(len) {
                        var output = this.textXOffset;
                        if (len > 10) {
                            output = this.textXOffset - len; 
                        }
                        return output;
                    },

                    renderGauge: function() {
                        var center = this.center,
                            renderer = this.renderer,
                            radius = renderer.height / 2,
                            value = this.formatValue(this.value),
                            inner_radius;

                        // the arc
                        this.elements.background = this.renderer.arc(
                            renderer.width/2,
                            renderer.height/2,
                            renderer.width/3,
                            renderer.width/3 - 20,
                            this.arcStart, this.arcFinish
                        ).attr({ 
                            fill: '#FFFFFF',
                            stroke: 'black',
                            'stroke-width': 1
                        }).add();
 
                        // draw the initial fill
                        this.drawFill(this.value);

                        // value display
                        this.elements.valueDisplay = this.renderer.text(
                            value,
                            ((renderer.width / 2) - ( this.predictTextWidth(value,Math.max(Math.round((renderer.width / 8)), 17) ) / 2)),
                            ((renderer.height / 2) + (renderer.height / 20))
                        ).css({
                            'font-size': Math.max(Math.round((renderer.width / 8)), 17).toString() + 'px',
                            'font-weight': 'bold'
                        }).add();

                        // gauge
                        if (this.gaugeUnits) {
                            this.elements.units = this.renderer.text(
                                this.gaugeUnits,
                                this.gaugeUnits + 15,
                                (renderer.height * .75) 
                            ).css({
                                'font-size': '20px',
                                'font-weight': 'bold'
                            }).add();
                        }

                        // label display
                        this.elements.labelDisplay = this.renderer.text(
                            this.primaryAxisTitle, 
                            ((renderer.width / 2) - ( this.predictTextWidth(this.primaryAxisTitle, 14) / 2)),
                            (renderer.height * .95)
                        ).css({
                            'font-size': '14px', 
                        }).add();
   
                    },
  
                    //override
                    onWindowResized: function(width, height) {
                        if (this.gaugeIsRendered) {
                            this.resize(Math.max(width, 20), Math.max(height, 20));
                        }
                    },

                    updateValue: function(oldValue, newValue) {
                        if (oldValue === newValue) {
                            return;
                        } else {
                            this.drawFill(newValue);
                        }
                        if (this.showValue) {
                            var valueText = this.formatValue(newValue);
                            this.updateValueDisplay(valueText);
                        }
                    },

                    updateValueDisplay: function(valueText) {
                        var renderer = this.renderer;

                        if (valueText.indexOf('.') !== -1) {
                            var decimal = valueText.split('.')[1];
                            if (decimal.length < this.maxValueDecimalLength) {
                                valueText += '0';
                            } else if (decimal.length > this.maxValueDecimalLength) {
                                valueText = valueText.split('.')[0] + '.' + decimal.substring(0,2); 
                            }
                        }
                        this.elements.valueDisplay.attr({
                            x: ((renderer.width / 2) - ( this.predictTextWidth(valueText,Math.max(Math.round((renderer.width / 8)), 17) ) / 2)),
                            text: valueText
                        }).css({
                            'font-size': Math.max(Math.round((renderer.width / 8)), 17).toString() + 'px'
                        });     
                    }

                }); 
                this.chart = new Splunk.JSCharting.NoelGauge(this.chartContainer); 
            } else {
                this.chart = Splunk.JSCharting.createChart(this.chartContainer, this.properties);
                this.chart.addEventListener('chartClicked', this.onChartClicked.bind(this));
                this.chart.addEventListener('legendClicked', this.onLegendClicked.bind(this));
            }

            this.chart.prepare(data, fieldInfo, this.properties);

            if(this.chart.needsColorPalette) {
                newFieldList = this.chart.getFieldList();
                this.applyColorsAndDraw(newFieldList, drawCallback);
            } else {
                this.chart.draw(drawCallback);
            }
              
        },

        onChartClicked: function($super, e) {
            var context = this.getContext();
            if (this.properties.chart == 'noelGauge') { 
                this.clicked = true;
                context.set('click', this.moduleId);
                this.pushContextToChildren(context);
            } else {
                $super(e); 
            }
        },

        isReadyForContextPush: function($super) {
            if (this.clicked === null) {
                return Splunk.Module.CANCEL;
            }
            return Splunk.Module.CONTINUE;
        }
 
    });

    Splunk.Module.JSChart.RenderThrottler = {

        DRAW_TIMEOUT_MULTIPLIER: (function() {
            var hasSVG = !!document.createElementNS &&
                                !!document.createElementNS("http://www.w3.org/2000/svg", "svg").createSVGRect;
            return hasSVG ? 10 : 200;
        })(),

        numPendingDraws: 0,

        registerPendingDraw: function() {
            this.numPendingDraws++;
        },

        unRegisterPendingDraw: function() {
            if(this.numPendingDraws > 0) {
                this.numPendingDraws--;
            }
        },

        getDebounceInterval: function() {
            return this.DRAW_TIMEOUT_MULTIPLIER * (this.numPendingDraws) + 10;
        }

    };

    Splunk.Module.JSChart.chartByIdMap = {};

    Splunk.Module.JSChart.getChartById = function(moduleId) {
        return this.chartByIdMap[moduleId];
    };

    Splunk.Module.JSChart.setChartById = function(moduleId, chart) {
        this.chartByIdMap[moduleId] = chart;
    };

}

/**
 * Customize the message module so it wont constantly be telling the user 
 * things that they dont care about and things that might alarm them.
 */
if (Splunk.Module.Message) {
    Splunk.Module.Message= $.klass(Splunk.Module.Message, {
        getHTMLTransform: function($super){
            var argh = [ 
                /*{contains:"The system is approaching the maximum number of historical", level:"warn"},
                {contains:"Assuming implicit lookup table with filename", level:"info"},
                {contains:"Your timerange was substituted", level:"info"},
                {contains:"Specified field(s) missing from results", level:"warn"},
                {contains:"Field extractor", level:"warn"},
                {contains:"Unable to find an eventtype", level:"warn"},
                {contains:"Ignoring eventtype", level:"warn"},*/
                {contains:"Subsearches of a real-time search run over all-time", level:"info"}
            ],  
            messages, message;

            // backwards compatibility due to Message module change
            if (this.displayedMessages !== undefined) {
                messages = this.displayedMessages; 
            } else messages = this.messages;

            for (var i=0; i<messages.length;){
                message = messages[i];
                for (var j=0; j<argh.length; j++) {
                    if (message !== undefined 
                    && (message.content.indexOf(argh[j]["contains"])!=-1) 
                    && (message.level == argh[j]["level"])) { 
                        messages.splice(i, 1);
                        // decrement the counter to account for the splice
                        i--;
                        break;
                    } 
                }   
                i++;
            }
            
            if (this.displayedMessages !== undefined) {
                this.displayedMessages = messages;
            } else this.messages = messages;
            
            return $super();
        }   
    }); 
}


// Augment the help link
if( $('#HadoopOpsAppBar_0_0_0').size() > 0 ){
   // retrieve help link
   var helpLink = $('.HadoopOpsAppBar a.help').attr("href");
   
   // replace "[splunk_for_hadoopops:" as "[HadoopOps:"
   helpLink = helpLink.replace('%5Bsplunk_for_hadoopops%3A', '%5BHadoopOps%3A');
   
   // replace ":major.minor.revision]" as ":major.minor]"
   var appVersion = helpLink.match(/%3A(\d+\.\d+).*%5D/);
   
   if (appVersion != null) {
      helpLink = helpLink.replace(appVersion[0], '%3A'.concat(appVersion[1],'%5D'));
   }
   
   // update help link
   $('.HadoopOpsAppBar a.help').attr("href", helpLink);
}

