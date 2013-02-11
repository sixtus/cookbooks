Splunk.Module.HadoopOpsMultiSelect = $.klass(Splunk.Module, {

    initialize: function($super, container) {

        $super(container);

        this.apply_from_context = Splunk.util.normalizeBoolean(this.getParam('apply_from_context'));
        this.earliest = this.getParam('earliest', '-1h');
        this.fill_on_empty = Splunk.util.normalizeBoolean(this.getParam('fill_on_empty'));
        this.header = null;
        this.inner_width = this.getParam('inner_width', '200');
        this.internal_search = null;
        this.is_changed = false;
        this.label = this.getParam('label');
        this.latest = this.getParam('latest', 'now');
        this.max_height = this.getParam('max_height', '225');
        this.menu = null;
        this.min_filter_len = 10;
        this.needs_init = true;
        this.outer_width = this.getParam('outer_width', 'auto');
        this.prev_selected = [];
        this.select = $("#" + this.moduleId + "_multiselect", this.container);
        this.selected_values = ['*'];
        this.search_string = this.getParam('search');
        this.token = this.getParam('field');

        if (this.fill_on_empty === true) {
            this.selected_values = null;
        }

        //load multiselect and filter 
        $script(Splunk.util.make_url('/modules/HadoopOpsMultiSelect/jquery.multiselect.js'),
            'mselect');
        $script(Splunk.util.make_url('/modules/HadoopOpsMultiSelect/jquery.multiselect.filter.js'), 
            'filter');
        $script.ready(['mselect', 'filter'], this.toggleInternalSearch.bind(this));
    },

    /*
     * override
     * we don't have any intentions, just a field 
     */
    getToken: function() {
        return this.token;
    },
  
    /*
     * when we receive an upstream context, look for options
     * if we instigated the change, we should not redraw our options
     */ 
    applyContext: function(context) {
        var options = context.get('options') || null,
            changed = context.get('changed') || null;
        if (options !== null && !($.isEmptyObject(options))) {
            if (changed === null
              || changed !== this.moduleId
              || options[this.getToken()].length > this.selected_values.length ) { 
                this.populateSelect(options[this.getToken()]);
            }
        } else {
            // pass if we haven't init'ed 
            if (this.needs_init === false) {
                this.removeOptions();
                this.updateSelect();
            }
        }
    },

    /*
     * select the given element
     * create it if not present 
     */ 
    selectSelector: function(elm, val) {
        if (elm.length === 0 && val !== '*') {
            this.select.append(
                $('<option>')
                    .val(val)
                    .text(val)
                    .attr('selected', 'selected')
            );
        } else {
            this.select.children('option[value="' + val + '"]')
                .attr('selected', 'selected');
        }
    },
    
    /*
     * if we received a selected mandate, select any matching elements
     */
    selectSelected: function() {
        var elm, i,
            selected = this.selected_values,
            widget = this.select.multiselect('widget');

        if (selected != null && selected != undefined) {
            // if selected is any array, we need to try to match all elements
            if ($.isArray(selected) === true && selected.length > 0) {
                for (i=0; i<selected.length; i++) {
                    elm = widget.find(':checkbox[value="' + selected[i] + '"]');
                    this.selectSelector(elm, selected[i]);
                }
            } else {
                elm = widget.find(':checkbox[value="' + selected + '"]');
                this.selectSelector(elm, selected);
            }
            this.reconcileSelected();
        } 
    },    
    
    /*
     * override 
     * set this form's context key to the currently selected values
     * set the changed flag if we are changing our form values
     */  
    getModifiedContext: function() {
        var context = this.getContext(),
            form = context.get('form') || {};

        if (this.token != null && this.token != undefined) {
            form[this.token] = this.selected_values;    
            context.set('form', form);
        }
        if (this.is_changed === true) {
            context.set('changed', this.moduleId);
        }
        this.is_changed = false;

        return context;
    },

    /*
     * override 
     * we have received a changed context indicating that we should set selected
     */
    onContextChange: function($super) {
        var context = this.getContext(),
            form = context.get('form');

        if (form !== null && form !== undefined && this.token !== null 
            && form.hasOwnProperty(this.token)) {
            if ($.isArray(form[this.token]) === false) {
                this.selected_values = new Array(form[this.token]);
            } else {
                this.selected_values = form[this.token];
            }
        }
    },

    /* 
     * override
     * because the default implementation freaks out in the case that the internal sid != context sid
     */ 
    getResults: function() {
        if (this.getResultsXHRObject) {
            if (this.getResultsXHRObject.readyState < 4) {
                var job = this.getContext().get("search").job;
                if (job && !job.isDone() && this.getResultsRetryCounter < this.getResultsRetryPolicy) {
                    this.getResultsRetryCounter++;
                    return;
                } else {
                    this.abortGetResults(); 
                    this.resetXHRStatus();
                }
            } else {
                this.resetXHRStatus();
            }
        }
        var params = this.getResultParams();
        this._previousResultParams = $.extend(true, {}, params);
        if (Splunk._testHarnessMode) {
            return false;
        }
        var resultUrl = this.getResultURL(params);
        var callingModule = this.moduleType;
        this.getResultsXHRObject = $.ajax({
            type: "GET",
            cache: ($.browser.msie ? false : true),
            url: resultUrl,
            beforeSend: function(xhr) {
                xhr.setRequestHeader('X-Splunk-Module', callingModule);
            },
            success: function(htmlFragment, textStatus, xhr) {
                if (xhr.status==0) {
                    return;
                }
                this.renderResults(htmlFragment);
                this.resetXHRStatus();
            }.bind(this),
            complete: this.getResultsCompleteHandler.bind(this),
            error: this.getResultsErrorHandler.bind(this)
        });
    },

    /*
     * override 
     * add sid and count
     */
    getResultParams: function($super) {
        var params = $super();
        params['sid'] = this.internal_search.job.getSearchId();
        return params;
    },

    /*
     * returns bool indicating whether or not current selection
     * represents a departure from the previous selection
     */
    isChanged: function(current) {
        if (this.prev_selected != undefined && this.prev_selected != null
            && current != undefined && current != null) {
            if (this.prev_selected.length == 0 && current.length === 0) {
                return false;
            } else if (this.prev_selected.length === current.length 
                       && this.prev_selected.length === this.prev_selected.filter(current).length) {
                return false;
            } else { 
                return true;
            }
        } else {
            return false;
        }
    },
 
    /*
     * callback for internal search failure
     */
    onDispatchFailure: function() {
        console.log('internal search failed');
    },

    /*
     * callback for internal search success 
     */
    onDispatchSuccess: function() {
       $(document).bind('jobDone', function(event, doneJob) {
            if (this.internal_search.job.getSearchId() == doneJob.getSearchId()) {
                this.onJobDone(event);
            }
        }.bind(this));
    },

    /*
     * callback for internal search job done
     */
    onJobDone: function() {
        this.getResults();
    },

    /*
     * callback handler for select/clear links
     */
    onLinkClick: function(event) {
        var target = $(event.currentTarget);
        if (target.hasClass('ui-multiselect-close') ){
            this.select.multiselect('close');
        } else {
            if (target.hasClass('ui-multiselect-all')) {
                this.select.multiselect('checkAll');
            } else {
                this.select.multiselect('uncheckAll');
            }
        }
        event.preventDefault();
    },

    /*
     * callback handler for menu close
     */
    onMenuClose: function(event) {
        this.reconcileSelected();
    },

    /*
     * callback handler for menu open 
     */
    onMenuOpen: function(event) {
        this.menu.css('width', this.inner_width)
            .css('height', 'auto')
            .css('max-height', this.max_height)
            .find('ul').last()
                .css('height', 'auto')
                .css('max-height', parseInt(this.max_height) - 25); 
    },

    /*
     * determines if there has been a change in selections
     * if so, replaces the terms in the search and pushes context
     */ 
    reconcileSelected: function() {
        var changed = false,
            values = [],
            current, i;

        // get the most current representation of the options
        this.select.multiselect('refresh');

        // get the currently checked options
        current = this.select.multiselect('getChecked');

        if (this.isChanged(current) !== false) {
            changed = true;
            this.prev_selected = current;
            for (i=0; i < current.length; i++) {
                values.push($(current[i]).val());
            }
            if (values.length > 0) {
                // we have values
                this.selected_values = values;
                this.updateSelected(); 
            } else {
                // we have no values
                if (this.fill_on_empty === true) {
                    this.selected_values = null;
                } else {
                    this.selected_values = ['*'];
                }
                this.select.multiselect('uncheckAll');
            }
        }
        this.is_changed = changed;

        // only push if we have something that has changed
        if (this.is_changed === true) {
            this.pushContextToChildren();
        }
    },

    /*
     * populate the select element from the given list
     */ 
    populateSelect: function(data) {
        var i;

        // insert options into DOM
        if (data !== undefined && data !== null 
            && $.isArray(data) === true) {
            this.removeOptions();
            for (i = 0; i < data.length; i++) {
                this.select.append($('<option>')
                    .val(data[i])
                    .text(data[i])
                );
            }
            if (this.needs_init === true) {
                this.initMultiSelect();
            } else {
                this.updateSelect();
            }
        }
    },

    /*
     * call requisite update methods
     */
    updateSelect: function() {
        this.selectSelected();
        this.select.multiselect('refresh');
        //$('input', this.menu).bind(['click.multiselect', 'click'], this.onOptionClick.bind(this));
        this.select.multiselectfilter('updateCache');
        this.toggleHeader();
    },

    /*
     * removes all options from select
     */ 
    removeOptions: function() {
        this.select.children('option').remove();
    },
 
    /*
     * override renderResults() to load json data
     */
    renderResults: function(data) {
        if (data !== undefined && data !== null
            && data.results !== undefined && data.results !== null) {
            this.populateSelect(data.results);
        }
    },

    /*
     * toggle the select header depending on children length
     */ 
    toggleHeader: function() {
        if (this.select.children().length < this.min_filter_len) {
            this.header.hide();
        } else {
            this.header.show();
        }
    },

    /*
     * intialize the multiselect
     */ 
    initMultiSelect: function() {
        var that = this;

        this.select.multiselect({
            checkAllText: 'All',
            close: function(event, ui) {
                      $('.ui-multiselect', that.container).css('border-radius', '4px 4px 4px 4px');
                      $('.ui-multiselect', that.container).css('border-bottom', '1px solid #9F9F9F');
                   },
            minWidth: 'auto',
            noneSelectedText: this.label,
            open: function(event, ui) {
                      $('.ui-multiselect', that.container).css('border-radius', '4px 4px 0 0');
                      $('.ui-multiselect', that.container).css('border-bottom', 'none');
                  },
            selectedList: 1,
            selectedText: that.updateSelected.bind(that),
            uncheckAllText: 'None'
        })
        .multiselectfilter({
            label: false,
            placeholder: 'search'
        });

        // select header and menu
        this.header = $('#ui-multiselect-header_' + this.moduleId);
        this.menu = $('#ui-multiselect-menu_' + this.moduleId);

        // hide header if less than minimum elements
        this.toggleHeader();

        // resize inner menu and checkboxes
        this.menu.css('width', this.inner_width)
            .find('.ui-multiselect-checkboxes')
                .css('width', this.inner_width);

        // bind link clicks
        $('a', this.header).bind('click.multiselect', this.onLinkClick.bind(this));

        // bind input checkbox click
        this.menu.bind('click.multiselect', this.onOptionClick.bind(this));

        // open callback
        this.select.bind('multiselectopen', this.onMenuOpen.bind(this));

        // close callback
        this.select.bind('multiselectclose', this.onMenuClose.bind(this));

        // in case a selected mandate has been given
        this.selectSelected();
  
        this.needs_init = false;

    },

    /*
     * handler for running the internal search 
     */
    toggleInternalSearch: function() {
        if (this.apply_from_context === false) {
            this.internal_search = new Splunk.Search(this.search_string, 
                                       new Splunk.TimeRange(this.earliest, this.latest)
                                   );
            this.internal_search.dispatchJob(
                this.onDispatchSuccess.bind(this), this.onDispatchFailure.bind(this)
            );
        }
    },

    /*
     * handler for checkbox clicks
     */ 
    onOptionClick: function(e, ui) { 
        var $target = $(e.target),
            val = $target.val(),
            $option;
        
        // filter out span clicks
        if ($target.is('input')) {
            // get the option and select it
            $option = this.select.children('option[value="' + val + '"]');
            $option.attr('selected', !$option.attr('selected'));
        }
    },

    /*
     * callback handler for menu close
     */
    updateSelected: function(event) {
        var selected = this.select.multiselect('getChecked').length.toString();
        return this.label + ' ' + selected + ' selected';
    }

});
