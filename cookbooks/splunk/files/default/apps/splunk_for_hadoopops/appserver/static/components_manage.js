Splunk.ServicesManager = (function() {

    var sm = {},
        // private props
        $selectAll = null,
        $caller = null,
        params = Splunk.util.queryStringToProp(window.location.search);

    // public props - used to cache jquery objects & misc for functionality
    sm.$table = null;
    sm.$rows = null;
    sm.$loading = null;
    sm._services = null;
    sm._callerId = params && params['callerId'];

    sm.init = function() {
        this.$table = $('#components_table');
        this.$rows = this.$table.find('tbody > tr');
        this.$loading = $('.ManageComponentsContainer .loading');
        this.resetServices();

        $selectAll = this.$table.find('th:first > input');
        $caller = (this._callerId) ? window.parent.$('#'+this._callerId)
                                   : window.parent.$('body');

        $('a.saveAll').click(this.saveAllHandler.bind(this));
        $('a.cancel').click(this.cancelHandler.bind(this));
        $selectAll.click(this.selectAllHandler.bind(this));

        // show delete icon upon row hover and handle click event
        this.$rows.mouseenter(function(e){
            $(this).find('td > a.delete').css('visibility', 'visible');
        }).mouseleave(function(e) {
            $(this).find('td > a.delete').css('visibility', 'hidden');
        }).find('td > a.delete').click(function(e){
            var $row = $(e.target).closest('tr').addClass('greyRow'),
                serviceItem = sm._services[$row.index()];
            if (confirm("Are you sure you want to remove\n"
                        + serviceItem.host + " | " + serviceItem.service + "?")) {
                // mark it to be deleted
                $row.data('to_delete', true);
                $row.slideUp('fast');
            } else {
                $row.removeClass('greyRow');
            }
        });
    };

    sm.resetServices = function() {
        // reset local copy of services based on current table
        this._services = this.parseTable();
    }

    sm.parseTable = function() {
        var services = [],
            fields = [];

        this.$table.find('tr').each(function(row_idx) {
            var $cols = $(this).children("th,td");
            if (row_idx === 0) {
                // head fields
                fields = $cols.map(function() {
                    field = $(this).data('field');
                    return (field) ? field : 'NA';
                }).get();
            } else {
                // body field values
                var service = {},
                    service_id = $(this).data('id'),
                    to_delete = $(this).data('to_delete');

                if (service_id) {
                    service['id'] = service_id
                }
                if (to_delete) {
                    service['to_delete'] = true;
                }
                var values = $cols.map(function() {
                    var $col = $(this),
                        $checkbox = $col.find('input:checkbox');
                    if ($checkbox.size() === 1) {
                        return $checkbox.is(':checked');
                    } else {
                        value = $(this).data('value');
                        return (value) ? value : $col.text();
                    }
                }).get();
                for (var i = 0; i < fields.length; i++) {
                    if (fields[i] !== 'NA') {
                        service[fields[i]] = values[i];
                    }
                }
                services.push(service);
            }
        });
        return services;
    };

    // TODO: this assumes getChangedServices is called only once before
    // removing service manager view. Otherwise, this may fail When there are
    // new services part of the set: saveAllHandler does not update IDs of those
    // services properly upon successful save, hence they're always considered 'new'.
    sm.getChangedServices = function() {
        return this.compareServicesSet(this._services, this.parseTable());
    };

    sm.compareServicesSet = function(servicesOld, servicesNew) {
        if (servicesOld.length !== servicesNew.length) {
            return false;
        }
        var services = [],
            service, i,
            l = servicesNew.length;
        for (i = 0; i < l; i++) {
            serviceOld = servicesOld[i];
            serviceNew = servicesNew[i];
            // add new services (no id attr), OR
            // add services that were edited
            if (!serviceOld.id || !this.areServicesEqual(serviceOld, serviceNew)) {
                services.push(serviceNew);
            }
        }
        return services;
    };

    sm.areServicesEqual = function(serviceA, serviceB) {
        for (var key in serviceA) {
            if (serviceA.hasOwnProperty(key)) {
                if (!serviceB.hasOwnProperty(key)) return false;
                if (serviceA[key] !== serviceB[key]) return false;
            }
        }
        for (var key in serviceB) {
            if (serviceB.hasOwnProperty(key)) {
                if (!serviceA.hasOwnProperty(key)) return false;
            }
        }
        return true;
    };

    sm.saveAllHandler = function(event) {
        event.preventDefault();
        var services = this.getChangedServices();
        if (!services || services.length == 0) {
            $caller.trigger('complete');
            return false;
        }

        // click handler to save all services
        var $target = $(event.target),
            url = $target.attr('href'),
            key = $target.attr('key'),
            that = this;

        this.$loading.show();
        $.ajax({
            url: url,
            type: 'POST',
            data: JSON.stringify(services),
            processData: false,
            contentType: 'application/json',
            dataType: 'json',
            beforeSend: function(xhr) {
                xhr.setRequestHeader('X-Splunk-Form-Key', key);
            },
            error: function(xhr, textStatus, errorThrown) {
                alert("Failed to save services: " + errorThrown);
                that.$loading.hide();
            },
            success: function(data) {
                that.$loading.hide();
                if (data && (data.success === false)) {
                    var errorMsg = "Failed to save services\n" + (data.error || "");
                    alert(errorMsg);
                } else {
                    that.resetServices();
                    // trigger complete event to caller which decides what to do
                    $caller.trigger('complete');
                }
            }
        });
        return false;
    };

    sm.cancelHandler = function(event) {
        event.preventDefault();
        return false;
    };

    sm.selectAllHandler = function(event) {
        if ($selectAll.is(':checked')) {
            this.$rows.find('td:first input').attr('checked', true);
        } else {
            this.$rows.find('td:first input').attr('checked', false);
        }
        return true;
    };

    $(document).ready(function() {
        sm.init();
    });

    return sm;
})();