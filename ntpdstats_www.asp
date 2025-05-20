<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>ntpMerlin</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<style>
p{font-weight:bolder}thead.collapsible-jquery{color:#fff;padding:0;width:100%;border:none;text-align:left;outline:none;cursor:pointer}td.nodata{height:65px!important;border:none!important;text-align:center!important;font:bolder 48px Arial!important}.SettingsTable{text-align:left}.SettingsTable input{text-align:left;margin-left:3px!important}.SettingsTable input.savebutton{text-align:center;margin-top:5px;margin-bottom:5px;border-right:solid 1px #000;border-left:solid 1px #000;border-bottom:solid 1px #000}.SettingsTable td.savebutton{border-right:solid 1px #000;border-left:solid 1px #000;border-bottom:solid 1px #000;background-color:#4d595d}.SettingsTable .cronbutton{text-align:center;min-width:50px;width:50px;height:23px;vertical-align:middle}.SettingsTable select{margin-left:3px!important}.SettingsTable label{margin-right:10px!important;vertical-align:top!important}.SettingsTable th{background-color:#1F2D35!important;background:#2F3A3E!important;border-bottom:none!important;border-top:none!important;font-size:12px!important;color:#fff!important;padding:4px!important;font-weight:bolder!important;padding:0!important}.SettingsTable td{word-wrap:break-word!important;overflow-wrap:break-word!important;border-right:none;border-left:none}.SettingsTable span.settingname{background-color:#1F2D35!important;background:#2F3A3E!important}.SettingsTable td.settingname{border-right:solid 1px #000;border-left:solid 1px #000;background-color:#1F2D35!important;background:#2F3A3E!important;width:35%!important}.SettingsTable td.settingvalue{text-align:left!important;border-right:solid 1px #000}.SettingsTable th:first-child{border-left:none!important}.SettingsTable th:last-child{border-right:none!important}.SettingsTable .invalid{background-color:#8b0000!important}.SettingsTable .disabled{background-color:#CCC!important;color:#888!important}.removespacing{padding-left:0!important;margin-left:0!important;margin-bottom:5px!important;text-align:center!important}div.sortTableContainer{height:300px;overflow-y:scroll;width:745px;border:1px solid #000}.sortTable{table-layout:fixed!important;border:none}thead.sortTableHeader th{background-image:linear-gradient(#92a0a5 0%,#66757c 100%);border-top:none!important;border-left:none!important;border-right:none!important;border-bottom:1px solid #000!important;font-weight:bolder;padding:2px;text-align:center;color:#fff;position:sticky;top:0;font-size:11px!important}thead.sortTableHeader th:first-child,thead.sortTableHeader th:last-child{border-right:none!important}thead.sortTableHeader th:first-child,thead.sortTableHeader td:first-child{border-left:none!important}tbody.sortTableContent td{border-bottom:1px solid #000!important;border-left:none!important;border-right:1px solid #000!important;border-top:none!important;padding:2px;text-align:center;overflow:hidden!important;white-space:nowrap!important;font-size:12px!important}tbody.sortTableContent tr.sortRow:nth-child(odd) td{background-color:#2F3A3E!important}tbody.sortTableContent tr.sortRow:nth-child(even) td{background-color:#475A5F!important}th.sortable{cursor:pointer}
</style>
<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/httpApi.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/moment.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chart.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/hammerjs.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-zoom.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-annotation.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/d3.js"></script>
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

/**----------------------------------------**/
/** Modified by Martinski W. [2025-Feb-20] **/
/**----------------------------------------**/

var custom_settings;
function loadCustomSettings()
{
	custom_settings = <% get_custom_settings(); %>;
	for (var prop in custom_settings)
	{
		if (Object.prototype.hasOwnProperty.call(custom_settings, prop))
		{
			if (prop.indexOf('ntpmerlin') !== -1 && prop.indexOf('ntpmerlin_version') === -1)
			{ eval("delete custom_settings." + prop) ; }
		}
	}
}

var arraysortlistlines=[],sortname="Time",sortdir="desc",maxNoCharts=18,currentNoCharts=0,ShowLines=GetCookie("ShowLines","string"),ShowFill=GetCookie("ShowFill","string"),DragZoom=!0,ChartPan=!1;Chart.defaults.global.defaultFontColor="#CCC",Chart.Tooltip.positioners.cursor=function(t,e){return e};var dataintervallist=["raw","hour","day"],metriclist=["Offset","Drift"],measureunitlist=["ms","ppm"],chartlist=["daily","weekly","monthly"],timeunitlist=["hour","day","day"],intervallist=[24,7,30],bordercolourlist=["#fc8500","#ffffff"],backgroundcolourlist=["rgba(252,133,0,0.5)","rgba(255,255,255,0.5)"];let databaseResetDone=0;var sqlDatabaseFileSize="0 Bytes",jffsAvailableSpaceStr="0 Bytes",jffsAvailableSpaceLow="OK";function keyHandler(t){82==t.keyCode?($(document).off("keydown"),ResetZoom()):68==t.keyCode?($(document).off("keydown"),ToggleDragZoom(document.form.btnDragZoom)):70==t.keyCode?($(document).off("keydown"),ToggleFill()):76==t.keyCode&&($(document).off("keydown"),ToggleLines())}function Draw_Chart_NoData(t,e){document.getElementById("divLineChart_"+t).width="730",document.getElementById("divLineChart_"+t).height="500",document.getElementById("divLineChart_"+t).style.width="730px",document.getElementById("divLineChart_"+t).style.height="500px";var a=document.getElementById("divLineChart_"+t).getContext("2d");a.save(),a.textAlign="center",a.textBaseline="middle",a.font="normal normal bolder 48px Arial",a.fillStyle="white",a.fillText(e,365,250),a.restore()}function Draw_Chart(t,e,a,i,n){var o=getChartPeriod($("#"+t+"_Period option:selected").val()),r=getChartInterval($("#"+t+"_Interval option:selected").val()),s=timeunitlist[$("#"+t+"_Period option:selected").val()],l=intervallist[$("#"+t+"_Period option:selected").val()],d=moment(),c=null,m=moment().subtract(l,s+"s"),u="line",f=window[t+"_"+r+"_"+o];if(null!=f)if(0!=f.length){var h=f.map((function(t){return t.Metric})),p=f.map((function(t){return{x:t.Time,y:t.Value}})),g=window["LineChart_"+t],y=getTimeFormat($("#Time_Format option:selected").val(),"axis"),b=getTimeFormat($("#Time_Format option:selected").val(),"tooltip");"day"==r&&(u="bar",c=moment().endOf("day").subtract(9,"hours"),m=moment().startOf("day").subtract(l-1,s+"s").subtract(12,"hours"),d=c),"daily"==o&&"day"==r&&(s="day",l=1,c=moment().endOf("day").subtract(9,"hours"),m=moment().startOf("day").subtract(12,"hours"),d=c),factor=0,"hour"==s?factor=36e5:"day"==s&&(factor=864e5),null!=g&&g.destroy();var v=document.getElementById("divLineChart_"+t).getContext("2d"),x={segmentShowStroke:!1,segmentStrokeColor:"#000",animationEasing:"easeOutQuart",animationSteps:100,maintainAspectRatio:!1,animateScale:!0,hover:{mode:"point"},legend:{display:!1,position:"bottom",onClick:null},title:{display:!0,text:e},tooltips:{callbacks:{title:function(t,e){return"day"==r?moment(t[0].xLabel,"X").format("YYYY-MM-DD"):moment(t[0].xLabel,"X").format(b)},label:function(t,e){return round(e.datasets[t.datasetIndex].data[t.index].y,3).toFixed(3)+" "+a}},mode:"point",position:"cursor",intersect:!0},scales:{xAxes:[{type:"time",gridLines:{display:!0,color:"#282828"},ticks:{min:m,max:c,display:!0},time:{parser:"X",unit:s,stepSize:1,displayFormats:y}}],yAxes:[{gridLines:{display:!1,color:"#282828"},scaleLabel:{display:!1,labelString:a},ticks:{display:!0,callback:function(t,e,i){return round(t,3).toFixed(3)+" "+a}}}]},plugins:{zoom:{pan:{enabled:ChartPan,mode:"xy",rangeMin:{x:m,y:getLimit(p,"y","min",!1)-.1*Math.sqrt(Math.pow(getLimit(p,"y","min",!1),2))},rangeMax:{x:d,y:getLimit(p,"y","max",!1)+.1*getLimit(p,"y","max",!1)}},zoom:{enabled:!0,drag:DragZoom,mode:"xy",rangeMin:{x:m,y:getLimit(p,"y","min",!1)-.1*Math.sqrt(Math.pow(getLimit(p,"y","min",!1),2))},rangeMax:{x:d,y:getLimit(p,"y","max",!1)+.1*getLimit(p,"y","max",!1)},speed:.1}}},annotation:{drawTime:"afterDatasetsDraw",annotations:[{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getAverage(p),borderColor:i,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg="+round(getAverage(p),3).toFixed(3)+a}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(p,"y","max",!0),borderColor:i,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:15,yAdjust:0,content:"Max="+round(getLimit(p,"y","max",!0),3).toFixed(3)+a}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(p,"y","min",!0),borderColor:i,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:15,yAdjust:0,content:"Min="+round(getLimit(p,"y","min",!0),3).toFixed(3)+a}}]}};g=new Chart(v,{type:u,data:{labels:h,datasets:[{data:p,borderWidth:1,pointRadius:1,lineTension:0,fill:ShowFill,backgroundColor:n,borderColor:i}]},options:x}),window["LineChart_"+t]=g}else Draw_Chart_NoData(t,"No data to display");else Draw_Chart_NoData(t,"No data to display")}function getLimit(t,e,a,i){var n,o=0;return n="x"==e?t.map((function(t){return t.x})):t.map((function(t){return t.y})),o="max"==a?Math.max.apply(Math,n):Math.min.apply(Math,n),"max"==a&&0==o&&0==i&&(o=1),o}function getAverage(t){for(var e=0,a=0;a<t.length;a++)e+=1*t[a].y;return e/t.length}function round(t,e){return Number(Math.round(t+"e"+e)+"e-"+e)}function ToggleLines(){""==ShowLines?(ShowLines="line",SetCookie("ShowLines","line")):(ShowLines="",SetCookie("ShowLines",""));for(var t=0;t<metriclist.length;t++){for(var e=0;e<3;e++)window["LineChart_"+metriclist[t]].options.annotation.annotations[e].type=ShowLines;window["LineChart_"+metriclist[t]].update()}}function ToggleFill(){"false"==ShowFill?(ShowFill="origin",SetCookie("ShowFill","origin")):(ShowFill="false",SetCookie("ShowFill","false"));for(var t=0;t<metriclist.length;t++)window["LineChart_"+metriclist[t]].data.datasets[0].fill=ShowFill,window["LineChart_"+metriclist[t]].update()}function redrawAllCharts(){for(var t=0;t<metriclist.length;t++){Draw_Chart_NoData(metriclist[t],"Data loading...");for(var e=0;e<chartlist.length;e++)for(var a=0;a<dataintervallist.length;a++)d3.csv("/ext/ntpmerlin/csv/"+metriclist[t]+"_"+dataintervallist[a]+"_"+chartlist[e]+".htm").then(SetGlobalDataset.bind(null,metriclist[t]+"_"+dataintervallist[a]+"_"+chartlist[e]))}}function SetGlobalDataset(t,e){if(window[t]=e,++currentNoCharts==maxNoCharts){document.getElementById("ntpupdate_text").innerHTML="",showhide("imgNTPUpdate",!1),showhide("ntpupdate_text",!1),showhide("btnUpdateStats",!0),showhide("databaseSize_text",!0);for(var a=0;a<metriclist.length;a++)$("#"+metriclist[a]+"_Interval").val(GetCookie(metriclist[a]+"_Interval","number")),changePeriod(document.getElementById(metriclist[a]+"_Interval")),$("#"+metriclist[a]+"_Period").val(GetCookie(metriclist[a]+"_Period","number")),Draw_Chart(metriclist[a],metriclist[a],measureunitlist[a],bordercolourlist[a],backgroundcolourlist[a]);AddEventHandlers(),get_lastx_file()}}function getTimeFormat(t,e){var a;return"axis"==e?0==t?a={millisecond:"HH:mm:ss.SSS",second:"HH:mm:ss",minute:"HH:mm",hour:"HH:mm"}:1==t&&(a={millisecond:"h:mm:ss.SSS A",second:"h:mm:ss A",minute:"h:mm A",hour:"h A"}):"tooltip"==e&&(0==t?a="YYYY-MM-DD HH:mm:ss":1==t&&(a="YYYY-MM-DD h:mm:ss A")),a}function GetCookie(t,e){return null!=cookie.get("ntp_"+t)?cookie.get("ntp_"+t):"string"==e?"":"number"==e?0:void 0}function SetCookie(t,e){cookie.set("ntp_"+t,e,3650)}function AddEventHandlers(){$(".collapsible-jquery").off("click").on("click",(function(){$(this).siblings().toggle("fast",(function(){"none"==$(this).css("display")?SetCookie($(this).siblings()[0].id,"collapsed"):SetCookie($(this).siblings()[0].id,"expanded")}))})),$(".collapsible-jquery").each((function(t,e){"collapsed"==GetCookie($(this)[0].id,"string")?$(this).siblings().toggle(!1):$(this).siblings().toggle(!0)}))}function setCurrentPage(){document.form.next_page.value=window.location.pathname.substring(1),document.form.current_page.value=window.location.pathname.substring(1)}function ErrorCSVExport(){document.getElementById("aExport").href="javascript:alert('Error exporting CSV,please refresh the page and try again')"}function ParseCSVExport(t){for(var e="Timestamp,Offset,Frequency,Sys_Jitter,Clk_Jitter,Clk_Wander,Rootdisp\n",a=0;a<t.length;a++){var i=t[a].Timestamp+","+t[a].Offset+","+t[a].Frequency+","+t[a].Sys_Jitter+","+t[a].Clk_Jitter+","+t[a].Clk_Wander+","+t[a].Rootdisp;e+=a<t.length-1?i+"\n":i}document.getElementById("aExport").href="data:text/csv;charset=utf-8,"+encodeURIComponent(e)}function initial(){setCurrentPage(),loadCustomSettings(),show_menu(),$("#sortTableContainer").empty(),$("#sortTableContainer").append(BuildLastXTableNoData()),getConfigFile(),d3.csv("/ext/ntpmerlin/csv/CompleteResults.htm").then((function(t){ParseCSVExport(t)})).catch((function(){ErrorCSVExport()})),$("#Time_Format").val(GetCookie("Time_Format","number")),scriptUpdateLayout(),getStatsTitleFile(),showhide("databaseSize_text",!0),showhide("jffsFreeSpace_text",!0),showhide("jffsFreeSpace_LOW",!1),showhide("jffsFreeSpace_WARN",!1),showhide("jffsFreeSpace_NOTE",!1),redrawAllCharts()}function scriptUpdateLayout(){var t=GetVersionNumber("local"),e=GetVersionNumber("server");$("#ntpmerlin_version_local").text(t),t!=e&&"N/A"!=e&&($("#ntpmerlin_version_server").text("Updated version available: "+e),showhide("btnChkUpdate",!1),showhide("ntpmerlin_version_server",!0),showhide("btnDoUpdate",!0))}function reload(){location.reload(!0)}function validateNumberSetting(t,e,a){t.name;var i=1*t.value;return i>e||i<a?($(t).addClass("invalid"),!1):($(t).removeClass("invalid"),!0)}function formatNumberSetting(t){t.name;var e=1*t.value;return 0!=t.value.length&&NaN!=e&&(t.value=parseInt(t.value),!0)}$(document).keydown((function(t){keyHandler(t)})),$(document).keyup((function(t){$(document).keydown((function(t){keyHandler(t)}))})),$.fn.serializeObject=function(){var t=custom_settings,e=this.serializeArray();return $.each(e,(function(){void 0!==t[this.name]&&-1!=this.name.indexOf("ntpmerlin")&&-1==this.name.indexOf("version")?(t[this.name].push||(t[this.name]=[t[this.name]]),t[this.name].push(this.value||"")):-1!=this.name.indexOf("ntpmerlin")&&-1==this.name.indexOf("version")&&(t[this.name]=this.value||"")})),t};const theDaysToKeepMIN=15,theDaysToKeepDEF=30,theDaysToKeepMAX=365,theDaysToKeepTXT=`(between ${theDaysToKeepMIN} and ${theDaysToKeepMAX}, default: ${theDaysToKeepDEF})`,theLastXResultsMIN=5,theLastXResultsDEF=10,theLastXResultsMAX=100,theLastXResultsTXT=`(between ${theLastXResultsMIN} and ${theLastXResultsMAX}, default: ${theLastXResultsDEF})`;function validateAll(){var t=!1;return validateNumberSetting(document.form.ntpmerlin_lastxresults,theLastXResultsMAX,theLastXResultsMIN)||(t=!0),validateNumberSetting(document.form.ntpmerlin_daystokeep,theDaysToKeepMAX,theDaysToKeepMIN)||(t=!0),!t||(alert("**ERROR**\nValidation for some fields failed.\nPlease correct invalid values and try again."),!1)}function getChartPeriod(t){var e="daily";return 0==t?e="daily":1==t?e="weekly":2==t&&(e="monthly"),e}function getChartInterval(t){var e="raw";return 0==t?e="raw":1==t?e="hour":2==t&&(e="day"),e}function changePeriod(t){value=1*t.value,name=t.id.substring(0,t.id.indexOf("_")),2==value?$('select[id="'+name+'_Period"] option:contains(24)').text("Today"):$('select[id="'+name+'_Period"] option:contains("Today")').text("Last 24 hours")}function ResetZoom(){for(var t=0;t<metriclist.length;t++){var e=window["LineChart_"+metriclist[t]];null!=e&&e.resetZoom()}}function ToggleDragZoom(t){var e=!0,a=!1,i="";-1!=t.value.indexOf("On")?(e=!1,a=!0,DragZoom=!1,ChartPan=!0,i="Drag Zoom Off"):(e=!0,a=!1,DragZoom=!0,ChartPan=!1,i="Drag Zoom On");for(var n=0;n<metriclist.length;n++){var o=window["LineChart_"+metriclist[n]];null!=o&&(o.options.plugins.zoom.zoom.drag=e,o.options.plugins.zoom.pan.enabled=a,t.value=i,o.update())}}function update_status(){$.ajax({url:"/ext/ntpmerlin/detect_update.js",dataType:"script",error:function(t){setTimeout(update_status,1e3)},success:function(){"InProgress"==updatestatus?setTimeout(update_status,1e3):(document.getElementById("imgChkUpdate").style.display="none",showhide("ntpmerlin_version_server",!0),"None"!=updatestatus?($("#ntpmerlin_version_server").text("Updated version available: "+updatestatus),showhide("btnChkUpdate",!1),showhide("btnDoUpdate",!0)):($("#ntpmerlin_version_server").text("No update available"),showhide("btnChkUpdate",!0),showhide("btnDoUpdate",!1)))}})}function checkUpdate(){showhide("btnChkUpdate",!1),document.formScriptActions.action_script.value="start_ntpmerlincheckupdate",document.formScriptActions.submit(),document.getElementById("imgChkUpdate").style.display="",setTimeout(update_status,2e3)}function doUpdate(){document.form.action_script.value="start_ntpmerlindoupdate",document.form.action_wait.value=10,showLoading(),document.form.submit()}function update_ntpstats(){$.ajax({url:"/ext/ntpmerlin/detect_ntpmerlin.js",dataType:"script",error:function(t){setTimeout(update_ntpstats,1e3)},success:function(){"InProgress"==ntpstatus?setTimeout(update_ntpstats,1e3):"GenerateCSV"==ntpstatus?(document.getElementById("ntpupdate_text").innerHTML="Retrieving data for charts...",setTimeout(update_ntpstats,1e3)):"Done"==ntpstatus&&(document.getElementById("ntpupdate_text").innerHTML="Refreshing charts...",postNTPUpdate())}})}function postNTPUpdate(){currentNoCharts=0,$("#Time_Format").val(GetCookie("Time_Format","number")),getStatsTitleFile(),setTimeout(redrawAllCharts,3e3)}function updateStats(){showhide("btnUpdateStats",!1),showhide("databaseSize_text",!1),document.formScriptActions.action_script.value="start_ntpmerlin",document.formScriptActions.submit(),document.getElementById("ntpupdate_text").innerHTML="Retrieving timeserver stats",showhide("imgNTPUpdate",!0),showhide("ntpupdate_text",!0),setTimeout(update_ntpstats,5e3)}function saveConfig(){validateAll()&&(document.getElementById("amng_custom").value=JSON.stringify($("form").serializeObject()),document.form.action_script.value="start_ntpmerlinconfig",document.form.action_wait.value=10,showLoading(),document.form.submit())}function GetVersionNumber(t){var e;return"local"==t?e=custom_settings.ntpmerlin_version_local:"server"==t&&(e=custom_settings.ntpmerlin_version_server),void 0===e||null==e?"N/A":e}function getConfigFile(){$.ajax({url:"/ext/ntpmerlin/config.htm",dataType:"text",error:function(t){setTimeout(getConfigFile,1e3)},success:function(data){let settingname,settingvalue;var configdata=data.split("\n");configdata=configdata.filter(Boolean);for(var indx=0;indx<configdata.length;indx++)0!==configdata[indx].length&&null===configdata[indx].match("^[ ]*#")&&(settingname=configdata[indx].split("=")[0],settingvalue=configdata[indx].split("=")[1].replace(/(\r\n|\n|\r)/gm,""),null==settingname.match(/^JFFS_MSGLOGTIME/)&&(settingname=settingname.toLowerCase(),eval("document.form.ntpmerlin_"+settingname).value=settingvalue));document.getElementById("theDaysToKeepText").textContent=theDaysToKeepTXT,document.getElementById("theLastXResultsText").textContent=theLastXResultsTXT}})}function getStatsTitleFile(){$.ajax({url:"/ext/ntpmerlin/ntpstatstext.js",dataType:"script",error:function(t){setTimeout(getStatsTitleFile,2e3)},success:function(){SetNTPDStatsTitle(),document.getElementById("databaseSize_text").textContent="Database Size: "+sqlDatabaseFileSize,null===jffsAvailableSpaceLow.match(/^WARNING[0-9]/)?(showhide("jffsFreeSpace_LOW",!1),showhide("jffsFreeSpace_NOTE",!1),showhide("jffsFreeSpace_WARN",!1),document.getElementById("jffsFreeSpace_text").textContent="JFFS Available: "+jffsAvailableSpaceStr):(document.getElementById("jffsFreeSpace_text").textContent="JFFS Available: ",document.getElementById("jffsFreeSpace_LOW").textContent=jffsAvailableSpaceStr,showhide("jffsFreeSpace_LOW",!0),"jffs"===document.form.ntpmerlin_storagelocation.value?(showhide("jffsFreeSpace_NOTE",!1),showhide("jffsFreeSpace_WARN",!0)):(showhide("jffsFreeSpace_WARN",!1),showhide("jffsFreeSpace_NOTE",!0))),1===databaseResetDone&&(currentNoCharts=0,$("#Time_Format").val(GetCookie("Time_Format","number")),redrawAllCharts(),databaseResetDone+=1),setTimeout(getStatsTitleFile,4e3)}})}function get_lastx_file(){$.ajax({url:"/ext/ntpmerlin/lastx.htm",dataType:"text",error:function(t){setTimeout(get_lastx_file,1e3)},success:function(t){ParseLastXData(t)}})}function ParseLastXData(t){var e=t.split("\n");e=e.filter(Boolean),arraysortlistlines=[];for(var a=0;a<e.length;a++)try{var i=e[a].split(","),n=new Object;n.Time=moment.unix(i[0].trim()).format("YYYY-MM-DD HH:mm:ss"),n.Offset=i[1].trim(),n.Drift=i[2].trim(),arraysortlistlines.push(n)}catch{}SortTable(sortname+" "+sortdir.replace("desc","↑").replace("asc","↓").trim())}function SortTable(sorttext){sortname=sorttext.replace("↑","").replace("↓","").trim();var sorttype="number",sortfield=sortname;switch(sortname){case"Time":sorttype="date";break}"string"==sorttype?-1==sorttext.indexOf("↓")&&-1==sorttext.indexOf("↑")||-1!=sorttext.indexOf("↓")?(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => (a."+sortfield+" > b."+sortfield+") ? 1 : ((b."+sortfield+" > a."+sortfield+") ? -1 : 0));"),sortdir="asc"):(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => (a."+sortfield+" < b."+sortfield+") ? 1 : ((b."+sortfield+" < a."+sortfield+") ? -1 : 0));"),sortdir="desc"):"number"==sorttype?-1==sorttext.indexOf("↓")&&-1==sorttext.indexOf("↑")?(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => parseFloat(a."+sortfield+'.replace("m","000")) - parseFloat(b.'+sortfield+'.replace("m","000")));'),sortdir="asc"):-1!=sorttext.indexOf("↓")?(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => parseFloat(a."+sortfield+'.replace("m","000")) - parseFloat(b.'+sortfield+'.replace("m","000"))); '),sortdir="asc"):(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => parseFloat(b."+sortfield+'.replace("m","000")) - parseFloat(a.'+sortfield+'.replace("m","000")));'),sortdir="desc"):"date"==sorttype&&(-1==sorttext.indexOf("↓")&&-1==sorttext.indexOf("↑")||-1!=sorttext.indexOf("↓")?(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => new Date(a."+sortfield+") - new Date(b."+sortfield+"));"),sortdir="asc"):(eval("arraysortlistlines = arraysortlistlines.sort((a,b) => new Date(b."+sortfield+") - new Date(a."+sortfield+"));"),sortdir="desc")),$("#sortTableContainer").empty(),$("#sortTableContainer").append(BuildLastXTable()),$(".sortable").each((function(t,e){e.innerHTML.replace(/ \(.*\)/,"").replace(" ","")==sortname&&(e.innerHTML="asc"==sortdir?e.innerHTML+" ↑":e.innerHTML+" ↓")}))}function BuildLastXTableNoData(){return"<tr>",'<td colspan="3" class="nodata">',"Data loading...","</td>","</tr>","</table>",'<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="sortTable"><tr><td colspan="3" class="nodata">Data loading...</td></tr></table>'}function BuildLastXTable(){var t='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="sortTable">';t+='<col style="width:150px;">',t+='<col style="width:280px;">',t+='<col style="width:280px;">',t+='<thead class="sortTableHeader">',t+="<tr>",t+='<th class="sortable" onclick="SortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Time</th>',t+='<th class="sortable" onclick="SortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Offset (ms)</th>',t+='<th class="sortable" onclick="SortTable(this.innerHTML.replace(/ \\(.*\\)/,\'\'))">Drift (ppm)</th>',t+="</tr>",t+="</thead>",t+='<tbody class="sortTableContent">';for(var e=0;e<arraysortlistlines.length;e++)t+='<tr class="sortRow">',t+="<td>"+arraysortlistlines[e].Time+"</td>",t+="<td>"+arraysortlistlines[e].Offset+"</td>",t+="<td>"+arraysortlistlines[e].Drift+"</td>",t+="</tr>";return t+="</tbody>",t+="</table>"}function changeChart(t){value=1*t.value,name=t.id.substring(0,t.id.indexOf("_")),SetCookie(t.id,value),"Offset"==name?Draw_Chart("Offset",metriclist[0],measureunitlist[0],bordercolourlist[0],backgroundcolourlist[0]):"Drift"==name&&Draw_Chart("Drift",metriclist[1],measureunitlist[1],bordercolourlist[1],backgroundcolourlist[1])}function changeAllCharts(t){value=1*t.value,name=t.id.substring(0,t.id.indexOf("_")),SetCookie(t.id,value);for(var e=0;e<metriclist.length;e++)Draw_Chart(metriclist[e],metriclist[e],measureunitlist[e],bordercolourlist[e],backgroundcolourlist[e])}

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
<input type="hidden" name="action_script" value="start_ntpmerlin">
<input type="hidden" name="action_wait" value="35">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="SystemCmd" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="amng_custom" id="amng_custom" value="">
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
<div class="formfonttitle" id="scripttitle" style="text-align:center;">ntpMerlin</div>
<div id="statstitle" style="text-align:center;">Stats last updated:</div>
<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
<div class="formfontdesc">ntpMerlin implements an NTP time server for AsusWRT Merlin with charts for daily, weekly and monthly summaries of performance. A choice between ntpd and chrony is available.</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons">
<thead class="collapsible-jquery" id="scripttools">
<tr><td colspan="2">Utilities (click to expand/collapse)</td></tr>
</thead>
<tr>
<th width="20%">Version information</th>
<td>
<span id="ntpmerlin_version_local" style="color:#FFFFFF;"></span>
&nbsp;&nbsp;&nbsp;
<span id="ntpmerlin_version_server" style="display:none;">Update version</span>
&nbsp;&nbsp;&nbsp;
<input type="button" class="button_gen" onclick="checkUpdate();" value="Check" id="btnChkUpdate">
<img id="imgChkUpdate" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
<input type="button" class="button_gen" onclick="doUpdate();" value="Update" id="btnDoUpdate" style="display:none;">
&nbsp;&nbsp;&nbsp;
</td>
</tr>
<tr>
<th width="20%">Update stats</th>
<td>
<input type="button" onclick="updateStats();" value="Update stats" class="button_gen" name="btnUpdateStats" id="btnUpdateStats">
<img id="imgNTPUpdate" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
&nbsp;&nbsp;&nbsp;
<span id="ntpupdate_text" style="display:none;"></span>
<!--
**-------------------------------------**
** Added by Martinski W. [2025-Feb-02] **
**-------------------------------------**
-->
<span id="databaseSize_text" style="margin-left:15px; display:none; font-size: 14px; font-weight: bolder;"></span>
</td>
</tr>
<tr>
<th width="20%">Export</th>
<td>
<a id="aExport" href="" download="ntpmerlin.csv"><input type="button" value="Export to CSV" class="button_gen" name="btnExport"></a>
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable SettingsTable" style="border:0px;" id="table_config">
<thead class="collapsible-jquery" id="scriptconfig">
<tr><td colspan="2">Configuration (click to expand/collapse)</td></tr>
</thead>
<tr class="even" id="rowtimeoutput">
<td class="settingname">Time Output Mode<br/><span class="settingname">(for CSV export)</span></td>
<td class="settingvalue">
<input type="radio" name="ntpmerlin_outputtimemode" id="ntpmerlin_timeoutput_non-unix" class="input" value="non-unix" checked>
<label for="ntpmerlin_timeoutput_non-unix">Non-Unix</label>
<input type="radio" name="ntpmerlin_outputtimemode" id="ntpmerlin_timeoutput_unix" class="input" value="unix">
<label for="ntpmerlin_timeoutput_unix">Unix</label>
</td>
</tr>
<tr class="even" id="rowstorageloc">
<td class="settingname">Data Storage Location</td>
<td class="settingvalue">
<input type="radio" name="ntpmerlin_storagelocation"
   id="ntpmerlin_storageloc_jffs" class="input" value="jffs" checked>
<label for="ntpmerlin_storageloc_jffs">JFFS</label>
<input type="radio" name="ntpmerlin_storagelocation"
   id="ntpmerlin_storageloc_usb" class="input" value="usb">
<label for="ntpmerlin_storageloc_usb">USB</label>
<!--
**-------------------------------------**
** Added by Martinski W. [2025-Feb-20] **
**-------------------------------------**
-->
<span id="jffsFreeSpace_text"
   style="margin-left:18px; display:none; font-size:12px; font-weight:bold;">JFFS Available</span>
<span id="jffsFreeSpace_LOW"
   style="margin-left:2px; padding-left:4px; padding-right:5px; display:none; font-size:12px; font-weight:bold; background-color:yellow; color:black;"></span>
<span id="jffsFreeSpace_WARN"
   style="margin-left:6px; padding-left:4px; padding-right:5px; display:none; font-size:12px; font-weight:bold; background-color:#C81927; color:#f2f2f2;"> <<< WARNING! </span>
<span id="jffsFreeSpace_NOTE"
   style="margin-left:6px; padding-left:4px; padding-right:5px; display:none; font-size:12px; font-weight:bold; background-color:#FF64FF; color:black;"> <<< NOTICE! </span>
</td>
</tr>
<tr class="even" id="rowtimeserver">
<td class="settingname">Timeserver</td>
<td class="settingvalue">
<input type="radio" name="ntpmerlin_timeserver" id="ntpmerlin_timeserver_ntpd" class="input" value="ntpd" checked>
<label for="ntpmerlin_timeserver_ntpd">NTPD</label>
<input type="radio" name="ntpmerlin_timeserver" id="ntpmerlin_timeserver_chronyd" class="input" value="chronyd">
<label for="ntpmerlin_timeserver_chronyd">Chrony</label>
</td>
</tr>
<tr class="even" id="rowlastxresults">
<td class="settingname">Last X results to display</td>
<td class="settingvalue">
<input autocomplete="off" type="text" maxlength="3"
   class="input_6_table removespacing" name="ntpmerlin_lastxresults" value="10"
   onkeypress="return validator.isNumber(this,event)"
   onblur="validateNumberSetting(this,theLastXResultsMAX,theLastXResultsMIN);formatNumberSetting(this)"
   onkeyup="validateNumberSetting(this,theLastXResultsMAX,theLastXResultsMIN)" data-lpignore="true"/>
&nbsp;results <span id="theLastXResultsText" style="margin-left:4px; color:#FFCC00;"></span>
</td>
</tr>
<tr class="even" id="rowdaystokeep">
<td class="settingname">Number of days of data to keep</td>
<td class="settingvalue">
<input autocomplete="off" type="text" maxlength="3"
   class="input_6_table removespacing" name="ntpmerlin_daystokeep" value="30"
   onkeypress="return validator.isNumber(this,event)"
   onblur="validateNumberSetting(this,theDaysToKeepMAX,theDaysToKeepMIN);formatNumberSetting(this)"
   onkeyup="validateNumberSetting(this,theDaysToKeepMAX,theDaysToKeepMIN)" data-lpignore="true"/>
&nbsp;days <span id="theDaysToKeepText" style="margin-left:4px; color:#FFCC00;"></span>
</td>
</tr>
<tr class="apply_gen" valign="top" height="35px">
<td colspan="2" class="savebutton">
<input type="button" onclick="saveConfig();" value="Save" class="button_gen savebutton" name="button">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="resulttable_timeserver">
<thead class="collapsible-jquery" id="resultthead_timeserver">
<tr><td colspan="2">Latest timeserver stats (click to expand/collapse)</td></tr>
</thead>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div id="sortTableContainer" class="sortTableContainer"></div>
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_charts">
<thead class="collapsible-jquery" id="thead_charts">
<tr>
<td>Charts (click to expand/collapse)</td>
</tr>
</thead>
<tr><td align="center" style="padding: 0px;">
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons2">
<thead class="collapsible-jquery" id="ntpmerlin_charttools">
<tr><td colspan="2">Chart Display Options (click to expand/collapse)</td></tr>
</thead>
<tr>
<th width="20%"><span style="color:#FFFFFF;background:#2F3A3E;">Time format</span><br /><span style="color:#FFCC00;background:#2F3A3E;">(for tooltips and Last 24h chart axis)</span></th>
<td>
<select style="width:100px" class="input_option" onchange="changeAllCharts(this)" id="Time_Format">
<option value="0">24h</option>
<option value="1">12h</option>
</select>
</td>
</tr>
<tr class="apply_gen" valign="top">
<td style="background-color:rgb(77, 89, 93);" colspan="2">
<input type="button" onclick="ToggleDragZoom(this);" value="Drag Zoom On" class="button_gen" name="btnDragZoom">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ResetZoom();" value="Reset Zoom" class="button_gen" name="btnResetZoom">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleLines();" value="Toggle Lines" class="button_gen" name="btnToggleLines">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleFill();" value="Toggle Fill" class="button_gen" name="btnToggleFill">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible-jquery" id="chart_offset">
<tr>
<td colspan="2">Offset (click to expand/collapse)</td>
</tr>
</thead>
<tr class="even">
<th width="40%">Data interval</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this);changePeriod(this);" id="Offset_Interval">
<option value="0">Raw</option>
<option value="1">Hours</option>
<option value="2">Days</option>
</select>
</td>
</tr>
<tr class="even">
<th width="40%">Period to display</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this)" id="Offset_Period">
<option value="0">Last 24 hours</option>
<option value="1">Last 7 days</option>
<option value="2">Last 30 days</option>
</select>
</td>
</tr>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_Offset" height="500" /></div>
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible-jquery" id="chart_drift">
<tr>
<td colspan="2">Drift (click to expand/collapse)</td>
</tr>
</thead>
<tr class="even">
<th width="40%">Data interval</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this);changePeriod(this);" id="Drift_Interval">
<option value="0">Raw</option>
<option value="1">Hours</option>
<option value="2">Days</option>
</select>
</td>
</tr>
<tr class="even">
<th width="40%">Period to display</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this)" id="Drift_Period">
<option value="0">Last 24 hours</option>
<option value="1">Last 7 days</option>
<option value="2">Last 30 days</option>
</select>
</td>
</tr>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_Drift" height="500" /></div>
</td>
</tr>
</table>
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
<input type="hidden" name="action_wait" value="">
</form>
<div id="footer"></div>
</body>
</html>
