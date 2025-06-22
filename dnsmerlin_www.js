
var $j = jQuery.noConflict();

/* ------------------------------------------------------------------
   dnsMerlin – minimal front‑end helpers
   (derived from ntpMerlin but stripped of all charts / NTP logic)
-------------------------------------------------------------------*/

// ---------- 1. read custom settings blob sent by dnsMerlin.sh -----
var custom_settings;
function LoadCustomSettings(){
    custom_settings = <% get_custom_settings(); %>;
    // prune legacy ntp keys if they still exist
    for (var prop in custom_settings){
        if(Object.prototype.hasOwnProperty.call(custom_settings, prop)){
            if(prop.indexOf('ntpmerlin') !== -1){
                delete custom_settings[prop];
            }
        }
    }
}

// ---------- 2. fetch dnsmasq.conf.add and populate textarea -------
function get_conf_file(){
    $j.ajax({
        url: "/jffs/configs/dnsmasq.conf.add",
        dataType: "text",
        cache: false,
        success: function(data){
            $j("#dnsmerlin_dnsmasq_lines").val(data.trim());
        },
        error: function(){
            alert("Failed to read /jffs/configs/dnsmasq.conf.add");
        }
    });
}

// ---------- 3. simple version label update -----------------------
function ScriptUpdateLayout(){
    var local = custom_settings.dnsmerlin_version_local || "N/A";
    var server = custom_settings.dnsmerlin_version_server || "N/A";
    $j("#dnsmerlin_version_local").text(local);
    if(local !== server && server !== "N/A"){
        $j("#dnsmerlin_version_server").text("Updated version available: " + server);
        $j("#dnsmerlin_version_server").show();
        $j("#btnDoUpdate").show();
        $j("#btnChkUpdate").hide();
    } else {
        $j("#dnsmerlin_version_server").hide();
        $j("#btnDoUpdate").hide();
        $j("#btnChkUpdate").show();
    }
}

// ---------- 4. utilities reused from original script -------------
function CheckUpdate(){
    document.formScriptActions.action_script.value = "start_dnsmerlincheckupdate";
    document.formScriptActions.submit();
    $j("#imgChkUpdate").show();
}

function DoUpdate(){
    document.form.action_script.value = "start_dnsmerlindoupdate";
    document.form.action_wait.value = 10;
    showLoading();
    document.form.submit();
}

// ---------- 5. serialise other inputs into custom_settings -------
$j.fn.serializeObject=function(){
    var obj = custom_settings;
    var arr = this.serializeArray();
    $j.each(arr, function(){
        obj[this.name] = this.value || "";
    });
    return obj;
};
