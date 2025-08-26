/* dnsMerlin JavaScript - Dynamic DNS Configuration Management */

var DNSMerlin = {
    addnHostsCounter: 0,
    originalConfig: '',
    hasUnsavedChanges: false,
    
    // Initialize the DNS configuration interface
    init: function() {
        this.setupEventHandlers();
        this.loadConfiguration();
        this.setupValidation();
        this.setupAutoSave();
    },
    
    // Setup event handlers for dynamic form interactions
    setupEventHandlers: function() {
        var self = this;
        
        // Add event listener for form changes
        $j(document).on('input change', 'input, select, textarea', function() {
            self.markUnsavedChanges();
            self.validateField(this);
        });
        
        // Setup collapsible sections
        $j('.collapsible-jquery').off('click').on('click', function() {
            $j(this).siblings().toggle('fast');
        });
        
        // Prevent accidental page navigation with unsaved changes
        window.addEventListener('beforeunload', function(e) {
            if (self.hasUnsavedChanges) {
                e.preventDefault();
                e.returnValue = 'You have unsaved changes. Are you sure you want to leave?';
                return 'You have unsaved changes. Are you sure you want to leave?';
            }
        });
    },
    
    // Load current DNS configuration
    loadConfiguration: function() {
        var self = this;
        
        $j.ajax({
            url: "/ext/dnsmerlin/dnsmasq.conf.add",
            dataType: "text",
            timeout: 10000,
            error: function(xhr, status, error) {
                self.showMessage('Error loading configuration: ' + error, 'error');
                // Load default configuration
                self.loadDefaultConfiguration();
            },
            success: function(data) {
                self.originalConfig = data;
                self.parseConfiguration(data);
                self.hasUnsavedChanges = false;
                self.updateSaveButton();
            }
        });
    },
    
    // Parse configuration data and populate form
    parseConfiguration: function(configData) {
        var lines = configData.split('\n');
        var addnHostsContainer = $j('#addnhosts-container');
        var dhcpHostsFile = '';
        var logQueries = false;
        var logFacility = '';
        
        // Clear existing entries
        addnHostsContainer.empty();
        this.addnHostsCounter = 0;
        
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line === '') continue;
            
            if (line.startsWith('#log-queries')) {
                logQueries = false;
            } else if (line === 'log-queries') {
                logQueries = true;
            } else if (line.startsWith('#log-facility=')) {
                logFacility = line.replace('#log-facility=', '');
            } else if (line.startsWith('log-facility=')) {
                logFacility = line.replace('log-facility=', '');
            } else if (line.startsWith('addn-hosts=')) {
                var path = line.replace('addn-hosts=', '').split('#')[0].trim();
                var comment = '';
                if (line.includes('#')) {
                    comment = line.split('#')[1].trim();
                }
                this.addAdднHostEntry(path, comment);
            } else if (line.startsWith('dhcp-hostsfile=')) {
                dhcpHostsFile = line.replace('dhcp-hostsfile=', '').split('#')[0].trim();
            }
        }
        
        // Set form values
        $j('#dhcp-hostsfile').val(dhcpHostsFile);
        $j('#log-queries').prop('checked', logQueries);
        $j('#log-facility').val(logFacility);
        
        // Add empty entry if no addn-hosts exist
        if (this.addnHostsCounter === 0) {
            this.addAdднHostEntry('', '');
        }
        
        // Update UI state
        this.updateLogFacilityState();
    },
    
    // Load default configuration if file doesn't exist
    loadDefaultConfiguration: function() {
        $j('#addnhosts-container').empty();
        this.addnHostsCounter = 0;
        
        // Add default entries based on your example
        this.addAdднHostEntry('/jffs/configs/hosts', '');
        this.addAdднHostEntry('/jffs/addons/YazDHCP.d/.hostnames', 'YazDHCP_hostnames');
        
        $j('#dhcp-hostsfile').val('/jffs/addons/YazDHCP.d/.staticlist');
        $j('#log-queries').prop('checked', false);
        $j('#log-facility').val('/tmp/dnsmasq.log');
        
        this.updateLogFacilityState();
    },
    
    // Add a new addn-hosts entry
    addAdднHostEntry: function(path, comment) {
        this.addnHostsCounter++;
        var container = $j('#addnhosts-container');
        var entryId = 'addnhost-' + this.addnHostsCounter;
        
        var entryHTML = '<div class="addnhost-entry" id="' + entryId + '">' +
            '<div style="margin-bottom: 8px;">' +
                '<label>Hosts File Path:</label>' +
                '<input type="text" name="addnhost-path-' + this.addnHostsCounter + '" ' +
                'value="' + this.escapeHtml(path || '') + '" ' +
                'placeholder="/jffs/configs/hosts" ' +
                'data-validation="path">' +
            '</div>' +
            '<div style="margin-bottom: 8px;">' +
                '<label>Comment:</label>' +
                '<input type="text" name="addnhost-comment-' + this.addnHostsCounter + '" ' +
                'value="' + this.escapeHtml(comment || '') + '" ' +
                'placeholder="Optional comment">' +
            '</div>' +
            '<div>' +
                '<input type="button" value="Remove" class="button_gen" ' +
                'onclick="DNSMerlin.removeAdднHostEntry(' + this.addnHostsCounter + ')" ' +
                'style="background-color: #8B0000;">' +
                '<span class="validation-message" style="margin-left: 10px; color: #ff6b6b; font-size: 12px;"></span>' +
            '</div>' +
        '</div>';
        
        container.append(entryHTML);
        this.markUnsavedChanges();
    },
    
    // Remove an addn-hosts entry
    removeAdднHostEntry: function(id) {
        var self = this;
        var entry = $j('#addnhost-' + id);
        
        if (entry.length) {
            entry.fadeOut(300, function() {
                $j(this).remove();
                self.markUnsavedChanges();
                
                // Ensure at least one entry exists
                if ($j('.addnhost-entry').length === 0) {
                    self.addAdднHostEntry('', '');
                }
            });
        }
    },
    
    // Add new addn-hosts entry (called from button)
    addNewAdднHost: function() {
        this.addAdднHostEntry('', '');
        
        // Scroll to the new entry
        setTimeout(function() {
            var newEntry = $j('.addnhost-entry').last();
            if (newEntry.length) {
                newEntry[0].scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                newEntry.find('input[type="text"]').first().focus();
            }
        }, 100);
    },
    
    // Validate individual form fields
    validateField: function(field) {
        var $field = $j(field);
        var value = $field.val().trim();
        var validation = $field.data('validation');
        var messageContainer = $field.closest('.addnhost-entry').find('.validation-message');
        
        if (!messageContainer.length) {
            messageContainer = $field.siblings('.validation-message');
        }
        
        var isValid = true;
        var message = '';
        
        if (validation === 'path' && value !== '') {
            // Validate file path
            if (!this.isValidPath(value)) {
                isValid = false;
                message = 'Invalid file path format';
            } else if (!value.startsWith('/')) {
                isValid = false;
                message = 'Path must be absolute (start with /)';
            }
        }
        
        // Update field appearance
        if (isValid) {
            $field.removeClass('invalid');
            messageContainer.text('');
        } else {
            $field.addClass('invalid');
            messageContainer.text(message);
        }
        
        return isValid;
    },
    
    // Validate complete form before saving
    validateForm: function() {
        var isValid = true;
        var self = this;
        
        // Validate all path fields
        $j('input[data-validation="path"]').each(function() {
            if (!self.validateField(this)) {
                isValid = false;
            }
        });
        
        // Validate that at least one addn-hosts entry has a path
        var hasValidAdднHost = false;
        $j('input[name^="addnhost-path-"]').each(function() {
            if ($j(this).val().trim() !== '') {
                hasValidAdднHost = true;
                return false;
            }
        });
        
        if (!hasValidAdднHost) {
            this.showMessage('At least one additional hosts file path is required', 'error');
            isValid = false;
        }
        
        return isValid;
    },
    
    // Check if path format is valid
    isValidPath: function(path) {
        // Basic path validation
        var pathRegex = /^\/[a-zA-Z0-9._\-\/]+$/;
        return pathRegex.test(path) && !path.includes('..');
    },
    
    // Update log facility field state based on log-queries checkbox
    updateLogFacilityState: function() {
        var logQueries = $j('#log-queries').prop('checked');
        var logFacilityField = $j('#log-facility');
        
        if (logQueries) {
            logFacilityField.prop('disabled', false).removeClass('disabled');
            logFacilityField.closest('tr').removeClass('disabled');
        } else {
            logFacilityField.prop('disabled', true).addClass('disabled');
            logFacilityField.closest('tr').addClass('disabled');
        }
    },
    
    // Save DNS configuration
    saveConfiguration: function() {
        if (!this.validateForm()) {
            return false;
        }
        
        var configLines = [];
        var self = this;
        
        // Process addn-hosts entries
        $j('input[name^="addnhost-path-"]').each(function() {
            var path = $j(this).val().trim();
            if (path !== '') {
                var id = $j(this).attr('name').split('-')[2];
                var comment = $j('input[name="addnhost-comment-' + id + '"]').val().trim();
                var line = 'addn-hosts=' + path;
                if (comment !== '') {
                    line += ' # ' + comment;
                }
                configLines.push(line);
            }
        });
        
        // Process dhcp-hostsfile
        var dhcpHostsFile = $j('#dhcp-hostsfile').val().trim();
        if (dhcpHostsFile !== '') {
            configLines.push('dhcp-hostsfile=' + dhcpHostsFile);
        }
        
        // Process logging options
        var logQueries = $j('#log-queries').prop('checked');
        var logFacility = $j('#log-facility').val().trim();
        
        if (logQueries) {
            configLines.push('log-queries');
            if (logFacility !== '') {
                configLines.push('log-facility=' + logFacility);
            } else {
                configLines.push('log-facility=/tmp/dnsmasq.log');
            }
        } else {
            configLines.push('#log-queries');
            if (logFacility !== '') {
                configLines.push('#log-facility=' + logFacility);
            } else {
                configLines.push('#log-facility=/tmp/dnsmasq.log');
            }
        }
        
        // Generate configuration data
        var configData = configLines.join('\n') + '\n';
        
        // Show loading state
        this.showMessage('Saving configuration...', 'loading');
        $j('#save-button').prop('disabled', true).val('Saving...');
        
        // Save configuration
        $j('#dns_config_data').val(configData);
        document.form.action_script.value = "start_dnsmerlinconfig";
        document.form.action_wait.value = 10;
        
        // Mark as saved
        this.hasUnsavedChanges = false;
        this.updateSaveButton();
        
        showLoading();
        document.form.submit();
        
        return true;
    },
    
    // Mark form as having unsaved changes
    markUnsavedChanges: function() {
        this.hasUnsavedChanges = true;
        this.updateSaveButton();
    },
    
    // Update save button appearance
    updateSaveButton: function() {
        var saveButton = $j('#save-button');
        if (this.hasUnsavedChanges) {
            saveButton.val('Save Configuration *').addClass('unsaved');
        } else {
            saveButton.val('Save Configuration').removeClass('unsaved');
        }
    },
    
    // Setup auto-save functionality
    setupAutoSave: function() {
        // Auto-save draft every 30 seconds
        var self = this;
        setInterval(function() {
            if (self.hasUnsavedChanges) {
                self.saveDraft();
            }
        }, 30000);
    },
    
    // Save draft configuration to localStorage
    saveDraft: function() {
        var draftData = {
            timestamp: new Date().toISOString(),
            addnHosts: [],
            dhcpHostsFile: $j('#dhcp-hostsfile').val(),
            logQueries: $j('#log-queries').prop('checked'),
            logFacility: $j('#log-facility').val()
        };
        
        // Collect addn-hosts entries
        $j('input[name^="addnhost-path-"]').each(function() {
            var id = $j(this).attr('name').split('-')[2];
            var path = $j(this).val().trim();
            var comment = $j('input[name="addnhost-comment-' + id + '"]').val().trim();
            
            if (path !== '') {
                draftData.addnHosts.push({ path: path, comment: comment });
            }
        });
        
        localStorage.setItem('dnsmerlin_draft', JSON.stringify(draftData));
    },
    
    // Load draft configuration from localStorage
    loadDraft: function() {
        var draftJson = localStorage.getItem('dnsmerlin_draft');
        if (!draftJson) return false;
        
        try {
            var draft = JSON.parse(draftJson);
            
            // Clear existing entries
            $j('#addnhosts-container').empty();
            this.addnHostsCounter = 0;
            
            // Load addn-hosts entries
            for (var i = 0; i < draft.addnHosts.length; i++) {
                this.addAdднHostEntry(draft.addnHosts[i].path, draft.addnHosts[i].comment);
            }
            
            // Load other settings
            $j('#dhcp-hostsfile').val(draft.dhcpHostsFile || '');
            $j('#log-queries').prop('checked', draft.logQueries || false);
            $j('#log-facility').val(draft.logFacility || '');
            
            this.updateLogFacilityState();
            this.markUnsavedChanges();
            
            return true;
        } catch (e) {
            console.error('Error loading draft:', e);
            return false;
        }
    },
    
    // Clear saved draft
    clearDraft: function() {
        localStorage.removeItem('dnsmerlin_draft');
    },
    
    // Show status messages
    showMessage: function(message, type) {
        var messageClass = 'success';
        if (type === 'error') messageClass = 'error';
        if (type === 'loading') messageClass = 'loading';
        
        var messageHtml = '<div class="message ' + messageClass + '">' + message + '</div>';
        
        // Remove existing messages
        $j('.message').remove();
        
        // Add new message
        $j('#FormTitle').prepend(messageHtml);
        
        // Auto-hide messages after 5 seconds (except loading)
        if (type !== 'loading') {
            setTimeout(function() {
                $j('.message').fadeOut(300);
            }, 5000);
        }
    },
    
    // Escape HTML characters
    escapeHtml: function(text) {
        var div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    },
    
    // Setup form validation
    setupValidation: function() {
        var self = this;
        
        // Log queries checkbox change handler
        $j('#log-queries').on('change', function() {
            self.updateLogFacilityState();
        });
        
        // Real-time validation for path fields
        $j(document).on('input', 'input[data-validation="path"]', function() {
            self.validateField(this);
        });
    }
};

// Initialize when DOM is ready
$j(document).ready(function() {
    DNSMerlin.init();
    
    // Check for saved draft on load
    if (DNSMerlin.loadDraft()) {
        DNSMerlin.showMessage('Draft configuration loaded. You have unsaved changes.', 'warning');
    }
});

// Global functions for onclick handlers
function AddNewAdднHost() {
    DNSMerlin.addNewAdднHost();
}

function SaveDNSConfig() {
    return DNSMerlin.saveConfiguration();
}