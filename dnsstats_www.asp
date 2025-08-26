<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>dnsMerlin</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<style>
p{font-weight:bolder}thead.collapsible-jquery{color:#fff;padding:0;width:100%;border:none;text-align:left;outline:none;cursor:pointer}td.nodata{height:65px!important;border:none!important;text-align:center!important;font:bolder 48px Arial!important}.SettingsTable{text-align:left}.SettingsTable input{text-align:left;margin-left:3px!important}.SettingsTable input.savebutton{text-align:center;margin-top:5px;margin-bottom:5px;border-right:solid 1px #000;border-left:solid 1px #000;border-bottom:solid 1px #000}.SettingsTable td.savebutton{border-right:solid 1px #000;border-left:solid 1px #000;border-bottom:solid 1px #000;background-color:#4d595d}.SettingsTable .cronbutton{text-align:center;min-width:50px;width:50px;height:23px;vertical-align:middle}.SettingsTable select{margin-left:3px!important}.SettingsTable label{margin-right:10px!important;vertical-align:top!important}.SettingsTable th{background-color:#1F2D35!important;background:#2F3A3E!important;border-bottom:none!important;border-top:none!important;font-size:12px!important;color:#fff!important;padding:4px!important;font-weight:bolder!important;padding:0!important}.SettingsTable td{word-wrap:break-word!important;overflow-wrap:break-word!important;border-right:none;border-left:none}.SettingsTable span.settingname{background-color:#1F2D35!important;background:#2F3A3E!important}.SettingsTable td.settingname{border-right:solid 1px #000;border-left:solid 1px #000;background-color:#1F2D35!important;background:#2F3A3E!important;width:35%!important}.SettingsTable td.settingvalue{text-align:left!important;border-right:solid 1px #000}.SettingsTable th:first-child{border-left:none!important}.SettingsTable th:last-child{border-right:none!important}.SettingsTable .invalid{background-color:#8b0000!important}.SettingsTable .disabled{background-color:#CCC!important;color:#888!important}.removespacing{padding-left:0!important;margin-left:0!important;margin-bottom:5px!important;text-align:center!important}div.sortTableContainer{height:300px;overflow-y:scroll;width:745px;border:1px solid #000}.sortTable{table-layout:fixed!important;border:none}thead.sortTableHeader th{background-image:linear-gradient(#92a0a5 0%,#66757c 100%);border-top:none!important;border-left:none!important;border-right:none!important;border-bottom:1px solid #000!important;font-weight:bolder;padding:2px;text-align:center;color:#fff;position:sticky;top:0;font-size:11px!important}thead.sortTableHeader th:first-child,thead.sortTableHeader th:last-child{border-right:none!important}thead.sortTableHeader th:first-child,thead.sortTableHeader td:first-child{border-left:none!important}tbody.sortTableContent td{border-bottom:1px solid #000!important;border-left:none!important;border-right:1px solid #000!important;border-top:none!important;padding:2px;text-align:center;overflow:hidden!important;white-space:nowrap!important;font-size:12px!important}tbody.sortTableContent tr.sortRow:nth-child(odd) td{background-color:#2F3A3E!important}tbody.sortTableContent tr.sortRow:nth-child(even) td{background-color:#475A5F!important}th.sortable{cursor:pointer}.addnhost-entry{margin-bottom:10px;padding:10px;border:1px solid #666;background-color:#2F3A3E}.addnhost-entry input[type="text"]{width:400px;margin-right:10px}.addnhost-entry input[type="button"]{margin-left:10px}.config-section{margin-bottom:20px;padding:15px;border:1px solid #666;background-color:#1F2D35}
</style>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/detect.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script>
var custom_settings;
var addnHostsCounter = 0;

function LoadCustomSettings(){
	custom_settings = <% get_custom_settings(); %>;
	for(var prop in custom_settings){
		if(Object.prototype.hasOwnProperty.call(custom_settings, prop)){
			if(prop.indexOf('dnsmerlin') != -1 && prop.indexOf('dnsmerlin_version') == -1){
				eval("delete custom_settings."+prop)
			}
		}
	}
}

function SetCurrentPage(){
	document.form.next_page.value=window.location.pathname.substring(1);
	document.form.current_page.value=window.location.pathname.substring(1);
}

function initial(){
	SetCurrentPage();
	LoadCustomSettings();
	show_menu();
	get_conf_file();
	ScriptUpdateLayout();
	LoadDNSConfigForm();
}

function ScriptUpdateLayout(){
	var localver = GetVersionNumber("local");
	var serverver = GetVersionNumber("server");
	$j("#dnsmerlin_version_local").text(localver);
	if(localver != serverver && serverver != "N/A"){
		$j("#dnsmerlin_version_server").text("Updated version available: " + serverver);
		showhide("btnChkUpdate", false);
		showhide("dnsmerlin_version_server", true);
		showhide("btnDoUpdate", true);
	}
}

function GetVersionNumber(source){
	var current;
	if(source == "local"){
		current = custom_settings.dnsmerlin_version_local;
	}
	else if(source == "server"){
		current = custom_settings.dnsmerlin_version_server;
	}
	
	if(typeof current == "undefined" || current == null){
		return "N/A";
	}
	else {
		return current;
	}
}

function LoadDNSConfigForm(){
	// Load current dnsmasq configuration
	$j.ajax({
		url: "/ext/dnsmerlin/dnsmasq.conf.add",
		dataType: "text",
		error: function(){
			console.log("Could not load dnsmasq.conf.add");
		},
		success: function(data){
			ParseDNSConfig(data);
		}
	});
}

function ParseDNSConfig(configData){
	var lines = configData.split('\n');
	var addnHostsContainer = $j('#addnhosts-container');
	var dhcpHostsFile = '';
	var logQueries = false;
	var logFacility = '';
	
	// Clear existing entries
	addnHostsContainer.empty();
	addnHostsCounter = 0;
	
	for(var i = 0; i < lines.length; i++){
		var line = lines[i].trim();
		if(line === '' || line.startsWith('#')) {
			if(line.includes('log-queries')){
				logQueries = false; // commented out
			}
			if(line.includes('log-facility=')){
				logFacility = line.replace('#log-facility=', '');
			}
			continue;
		}
		
		if(line.startsWith('addn-hosts=')){
			var path = line.replace('addn-hosts=', '').split('#')[0].trim();
			var comment = '';
			if(line.includes('#')){
				comment = line.split('#')[1].trim();
			}
			AddAdднHostEntry(path, comment);
		}
		else if(line.startsWith('dhcp-hostsfile=')){
			dhcpHostsFile = line.replace('dhcp-hostsfile=', '').split('#')[0].trim();
		}
		else if(line === 'log-queries'){
			logQueries = true;
		}
		else if(line.startsWith('log-facility=')){
			logFacility = line.replace('log-facility=', '');
		}
	}
	
	// Set form values
	document.getElementById('dhcp-hostsfile').value = dhcpHostsFile;
	document.getElementById('log-queries').checked = logQueries;
	document.getElementById('log-facility').value = logFacility;
	
	// Add empty entry if no addn-hosts exist
	if(addnHostsCounter === 0){
		AddAdднHostEntry('', '');
	}
}

function AddAdднHostEntry(path, comment){
	addnHostsCounter++;
	var container = $j('#addnhosts-container');
	var entryHTML = '<div class="addnhost-entry" id="addnhost-' + addnHostsCounter + '">' +
		'<label>Hosts File Path:</label>' +
		'<input type="text" name="addnhost-path-' + addnHostsCounter + '" value="' + (path || '') + '" placeholder="/jffs/configs/hosts">' +
		'<label>Comment:</label>' +
		'<input type="text" name="addnhost-comment-' + addnHostsCounter + '" value="' + (comment || '') + '" placeholder="Optional comment">' +
		'<input type="button" value="Remove" onclick="RemoveAdднHostEntry(' + addnHostsCounter + ')">' +
		'</div>';
	container.append(entryHTML);
}

function RemoveAdднHostEntry(id){
	$j('#addnhost-' + id).remove();
}

function AddNewAdднHost(){
	AddAdднHostEntry('', '');
}

function SaveDNSConfig(){
	var configLines = [];
	
	// Process addn-hosts entries
	$j('input[name^="addnhost-path-"]').each(function(){
		var path = $j(this).val().trim();
		if(path !== ''){
			var id = $j(this).attr('name').split('-')[2];
			var comment = $j('input[name="addnhost-comment-' + id + '"]').val().trim();
			var line = 'addn-hosts=' + path;
			if(comment !== ''){
				line += ' # ' + comment;
			}
			configLines.push(line);
		}
	});
	
	// Process dhcp-hostsfile
	var dhcpHostsFile = document.getElementById('dhcp-hostsfile').value.trim();
	if(dhcpHostsFile !== ''){
		configLines.push('dhcp-hostsfile=' + dhcpHostsFile);
	}
	
	// Process logging options
	var logQueries = document.getElementById('log-queries').checked;
	var logFacility = document.getElementById('log-facility').value.trim();
	
	if(logQueries){
		configLines.push('log-queries');
	} else {
		configLines.push('#log-queries');
	}
	
	if(logFacility !== ''){
		if(logQueries){
			configLines.push('log-facility=' + logFacility);
		} else {
			configLines.push('#log-facility=' + logFacility);
		}
	} else {
		configLines.push('#log-facility=/tmp/dnsmasq.log');
	}
	
	// Send configuration to server
	var configData = configLines.join('\n') + '\n';
	
	// Set the configuration data in a hidden field and submit
	document.getElementById('dns_config_data').value = configData;
	document.form.action_script.value="start_dnsmerlinconfig";
	document.form.action_wait.value=10;
	showLoading();
	document.form.submit();
}

function get_conf_file(){
	$j.ajax({
		url: "/ext/dnsmerlin/config.htm",
		dataType: "text",
		error: function(){
			setTimeout(get_conf_file, 1000);
		},
		success: function(data){
			var configdata = data.split("\n");
			configdata = configdata.filter(Boolean);
			for(var i = 0; i < configdata.length; i++){
				eval("document.form.dnsmerlin_" + configdata[i].split("=")[0].toLowerCase()).value = configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");
			}
		}
	});
}

$j.fn.serializeObject = function(){
	var o = custom_settings;
	var a = this.serializeArray();
	$j.each(a, function() {
		if (o[this.name] !== undefined && this.name.indexOf("dnsmerlin") != -1 && this.name.indexOf("version") == -1) {
			if (!o[this.name].push) {
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else if(this.name.indexOf("dnsmerlin") != -1 && this.name.indexOf("version") == -1) {
			o[this.name] = this.value || '';
		}
	});
	return o;
};

function CheckUpdate(){
	showhide("btnChkUpdate", false);
	document.formScriptActions.action_script.value="start_dnsmerlincheckupdate";
	document.formScriptActions.submit();
	document.getElementById("imgChkUpdate").style.display = "";
	setTimeout(update_status, 2000);
}

function DoUpdate(){
	document.form.action_script.value="start_dnsmerlindoupdate";
	document.form.action_wait.value=10;
	showLoading();
	document.form.submit();
}

function update_status(){
	$j.ajax({
		url: "/ext/dnsmerlin/detect_update.js",
		dataType: "script", 
		error: function(){
			setTimeout(update_status, 1000);
		},
		success: function(){
			if(updatestatus == "InProgress"){
				setTimeout(update_status, 1000);
			}
			else {
				document.getElementById("imgChkUpdate").style.display = "none";
				showhide("dnsmerlin_version_server", true);
				if(updatestatus == "None"){
					$j("#dnsmerlin_version_server").text("No update available");
					showhide("btnChkUpdate", true);
					showhide("btnDoUpdate", false);
				}
				else {
					$j("#dnsmerlin_version_server").text("Updated version available: " + updatestatus);
					showhide("btnChkUpdate", false);
					showhide("btnDoUpdate", true);
				}
			}
		}
	});
}
</script>
</head>
<body onload="initial();" onunload="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="about:blank" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="start_dnsmerlin">
<input type="hidden" name="action_wait" value="35">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="SystemCmd" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="amng_custom" id="amng_custom" value="">
<input type="hidden" name="dns_config_data" id="dns_config_data" value="">
<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr>
<td width="17">&nbsp;</td>
<td valign="top" width="202">
<div id="mainMenu"></div>
<div id="subMenu"></div></td>
<td valign="top">
<div id="tabMenu" class="submenuBlock"></div>
<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
<tr>
<td valign="top">
<table width="760px" border="0" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
<tbody>
<tr bgcolor="#4D595D">
<td valign="top">
<div>&nbsp;</div>
<div class="formfonttitle" id="scripttitle" style="text-align:center;">dnsMerlin</div>
<div id="statstitle" style="text-align:center;">DNS Configuration Manager</div>
<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
<div class="formfontdesc">dnsMerlin provides a web interface for managing dnsmasq configuration on AsusWRT Merlin. Configure additional host files, DHCP static assignments, and DNS logging options.</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons">
<thead class="collapsible-jquery" id="scripttools">
<tr><td colspan="2">Utilities (click to expand/collapse)</td></tr>
</thead>
<tr>
<th width="20%">Version information</th>
<td>
<span id="dnsmerlin_version_local" style="color:#FFFFFF;"></span>
&nbsp;&nbsp;&nbsp;
<span id="dnsmerlin_version_server" style="display:none;">Update version</span>
&nbsp;&nbsp;&nbsp;
<input type="button" class="button_gen" onclick="CheckUpdate();" value="Check" id="btnChkUpdate">
<img id="imgChkUpdate" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
<input type="button" class="button_gen" onclick="DoUpdate();" value="Update" id="btnDoUpdate" style="display:none;">
&nbsp;&nbsp;&nbsp;
</td>
</tr>
</table>

<div style="line-height:10px;">&nbsp;</div>

<!-- DNS Configuration Section -->
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="SettingsTable" id="table_config">
<thead class="collapsible-jquery" id="dnsconfig">
<tr><td colspan="2">DNS Configuration (click to expand/collapse)</td></tr>
</thead>

<!-- Additional Hosts Files Section -->
<tr>
<td class="settingname">Additional Host Files<br><i>Configure additional hosts files for custom DNS entries</i></td>
<td class="settingvalue">
<div id="addnhosts-container">
<!-- Dynamic content will be loaded here -->
</div>
<input type="button" class="button_gen" onclick="AddNewAdднHost();" value="Add New Host File">
</td>
</tr>

<!-- DHCP Hosts File Section -->
<tr>
<td class="settingname">DHCP Static Hosts File<br><i>File containing DHCP static IP assignments</i></td>
<td class="settingvalue">
<input type="text" id="dhcp-hostsfile" name="dhcp-hostsfile" style="width:400px;" placeholder="/jffs/addons/YazDHCP.d/.staticlist">
</td>
</tr>

<!-- Logging Configuration Section -->
<tr>
<td class="settingname">Enable Query Logging<br><i>Log all DNS queries</i></td>
<td class="settingvalue">
<input type="checkbox" id="log-queries" name="log-queries">
<label for="log-queries">Enable DNS query logging</label>
</td>
</tr>

<tr>
<td class="settingname">Log File Path<br><i>Location for DNS query logs</i></td>
<td class="settingvalue">
<input type="text" id="log-facility" name="log-facility" style="width:400px;" placeholder="/tmp/dnsmasq.log">
</td>
</tr>

<!-- Save Button -->
<tr>
<td class="savebutton" colspan="2">
<input type="button" class="button_gen savebutton" onclick="SaveDNSConfig();" value="Save Configuration">
</td>
</tr>

</table>

</td>
</tr>
</tbody>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>
</form>

<form method="post" name="formScriptActions" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_wait" value="3">
</form>
</body>
</html>