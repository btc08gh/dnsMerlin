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
<link rel="stylesheet" type="text/css" href="/user/dnsmerlin/dnsmerlin_www.css">
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/moment.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/detect.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/user/dnsmerlin/dnsmerlin_www.js"></script>
<script>
function GetCookie(k, t){var v;if(null!=(v=cookie.get("dns_"+k)))return v;return"string"==t?"":"number"==t?0:void 0}
function SetCookie(k, v){cookie.set("dns_"+k,v,3650)}
function SaveConfig(){
  document.getElementById('amng_custom').value =
    JSON.stringify($j('form').serializeObject());
  document.form.action_script.value = 'start_dnsmerlinconfig';
  document.form.action_wait.value   = 10;
  showLoading();
  document.form.submit();
}
function initial(){
  LoadCustomSettings();
  show_menu();
  get_conf_file();
  ScriptUpdateLayout();
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
<input type="hidden" name="preferred_lang" id="preferred_lang" value="">
<input type="hidden" name="firmver"        value="">
<input type="hidden" name="amng_custom"    id="amng_custom" value="">
<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr><td width="17">&nbsp;</td><td valign="top" width="202"><div id="mainMenu"></div><div id="subMenu"></div></td>
<td valign="top"><div id="tabMenu" class="submenuBlock"></div>
<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0"><tr><td valign="top">
<table width="760px" border="0" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
<tbody><tr bgcolor="#4D595D"><td valign="top"><div>&nbsp;</div>
<div class="formfonttitle" id="scripttitle" style="text-align:center;">dnsMerlin</div>
<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
<div class="formfontdesc">dnsMerlin equips AsusWRT Merlin with a full-featured DNS layer and a streamlined WebUI for editing DNSMasq options.</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons">
<thead class="collapsible-jquery" id="scripttools"><tr><td colspan="2">Utilities (click to expand/collapse)</td></tr></thead>
<tr><th width="20%">Version information</th><td>
<span id="dnsmerlin_version_local"  style="color:#FFFFFF;"></span>&nbsp;&nbsp;&nbsp;
<span id="dnsmerlin_version_server" style="display:none;">Update version</span>&nbsp;&nbsp;&nbsp;
<input type="button" class="button_gen" onclick="CheckUpdate();" value="Check"  id="btnChkUpdate">
<img id="imgChkUpdate" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
<input type="button" class="button_gen" onclick="DoUpdate();"   value="Update" id="btnDoUpdate" style="display:none;">
</td></tr></table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable SettingsTable" id="table_config">
<thead class="collapsible-jquery" id="scriptconfig"><tr><td colspan="2">Configuration (click to expand/collapse)</td></tr></thead>
<tr class="even" id="rowdnslist"><td class="settingname">dnsmasq.conf.add lines<br/><span class="settingname">(one per line)</span></td>
<td class="settingvalue">
<textarea name="dnsmerlin_dnsmasq_lines" id="dnsmerlin_dnsmasq_lines" rows="10" cols="60" style="width:100%;"></textarea>
</td></tr>
<tr class="apply_gen" valign="top" height="35px"><td colspan="2" class="savebutton">
<input type="button" onclick="SaveConfig();" value="Save" class="button_gen savebutton" name="button">
</td></tr></table></td></tr></tbody></table></td></tr></table></td></tr></table>
</form>
<form method="post" name="formScriptActions" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_wait" value="">
</form>
<div id="footer"></div>
</body></html>
