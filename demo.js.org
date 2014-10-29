// @(#) $Id$
// :vim se ts=2 expandtab:
$ = jQuery
/*Handle requests from background.html*/
function handleRequest(request, sender, sendResponse) {
  if (request && request.callFunction)
    if (request.callFunction == "toggleSB")
      toggleSB();
    else if (request.callFunction == "genTicket")
      genTicket();
}
chrome.extension.onRequest.addListener(handleRequest);

/*Small function wich create a sidebar(just to illustrate my point)*/
var sidebarOpen = false;
var cssInjected = false;
var openTickets = [];
var aeTickets = [];
var genIvl = 5;
var genIvlId = null;
var openCnt = null;
var uls = {};
var otcid = 1;
var maxAssigned = 5;
function toggleSB() {
  if(sidebarOpen) {
    console.log("disabling sidebar and genIvl: " + genIvl);
    if (genIvlId) clearInterval(genIvlId);
    var el = document.getElementById('mySidebar');
    el.parentNode.removeChild(el);
  } else {
/*    if (!cssInjected) {

      console.log("adding css/styles.css");
      var link = document.createElement("link");
      link.href = chrome.extension.getURL("css/styles.css");
      link.type = "text/css";
      link.rel = "stylesheet";
      document.getElementsByTagName("head")[0].appendChild(link);
    }
*/
    console.log("checking notifications for this page");
    checkReqNotify();
    console.log("adding div");

    var navBar = '<div class="navbar navbar-custom"><div class="navbar-inner"><a class="brand" href="#">JJR@DevOps</a><ul class="nav"><li class="active"><a href="#">Open</a></li><li><a href="#">Servers</a></li><li><a href="#">Users</a></li><li><a href="#">Perms</a></ul></div></div>';

    var sbListHead = '<div><h4>Open Requests <span class="badge openCnt">0</span></h1><ul class="nav-list" id="listHead"></ul></div>';

    var sbListTop = '<div><h4>Assigned Requests (Accepted: <span class="badge acceptCnt">1</span>)</h4><ul id="listTop" class="nav-list"></ul></div>';
    //var sbNav='<button class="btn", id="servers">Servers</button>' +
    //  '<button class="btn", id="users">Users</button>';
    var sbContentMain = '<div> <ul id="contentMain"> </ul> <div>';
    var sidebar = document.createElement('div');
    sidebar.id    = "mySidebar";
    sidebar.class = "mysidebar";
    sidebar.innerHTML = navBar +sbListHead + sbListTop + sbContentMain;
    document.body.appendChild(sidebar);
    var sbContentMain = '<div> <ul id="contentMain"> </ul> <div>';
    var sidebar = document.createElement('div');
    console.log("sidebar div added. Adding empty lists");
    uls = { head: $("#listHead"), top: $("#listTop") };
    console.log("sidebar div added. Adding empty lists head: " + uls.head + ", and top: " + uls.top);
    console.log("setting up a genTicket every " + genIvl + " secs");
    genIvlId = setInterval(genTicket, genIvl * 1000);
    initLists();
  }
  sidebarOpen = !sidebarOpen;
}
function initLists() {
  console.log("Initializing lists...");
  openTickets.forEach( function(e) { insElement(e, uls.head)});
  aeTickets.forEach( function(e)   { insElement(e, uls.top) });
}
function addElement(el, ul, ary) {
  ary.push(el);
  console.log("Adding at ticket for " + el.class);
  insElement(el, ul);
  updCounters(ul);
}
function insElement(el, ul) {
  console.log("insEl: " + el.class);
  var labclass = "label-info";
  var ae = el.ae ? " - " + el.ae: "";
  var nTitle = el.st + ' - ' + el.app + ' - ' + el.cmp;
  var nOpts = { body: el.detail, icon: "icon.png", tag: el.class };
  if (el.status == "Open") { 
	if (document.webkitVisibilityState !== "visible")
		el.closer = notify.createNotification(nTitle, nOpts); 
	labclass = "label-warning active"; 
  }
  var html = '<li class="' + el.class + '">' + nTitle + ': <span class="label ' + labclass + '">' + el.status + ae + '</span></li>';
  $(html).hide().prependTo(ul).fadeIn(1900);
  //console.log("insEl: after ul.append: ul.length is: " + ul.length);
}
// old school - todo: replace with lodash
function findElement(sel, ary) {
  console.log("findEl: ary.length");
  for (var i in ary) if (sel(ary[i], i)) return i;
  console.log("findEl: did not find " + sel);
}
function removeElement(sel, ul, ary) {
  console.log("remEl: " + sel + " of " + ul.length);
  console.dir(ul);
  var found = findElement(function(e) { return e.class === sel; }, ary);
  if (found) {
    var ret = ary.splice(found, 1)[0];
    if (ret.closer) ret.closer.close();
    console.log("found " + found + ":" + ret);
    $(ul.find("li." + sel)).remove();
    updCounters(ul);
    return ret;
  } else {
    console.log("didnt find " + sel  + " in " + ul);
  }
}
function removeLast(ul, ary) {
  console.log("remLast of " + ary.length + "(" + ul.length + ")"  );  
  if (ary.length > 0 && ul.length > 0) {
    var last = ary.pop();
    if (last.closer) last.closer.close();
    ul.last().remove();
    console.log("remLast of " + ary.length + "("+ul.length+")"  );  
  } else {
    console.log("No last element to remove");
  }
}
function updCounters(ul) { 
  if (!openCnt) openCnt = $(".openCnt"); 
  openCnt.text(openTickets.length); 
}
function genTicket() { 
  var apps = [ "eP AuthHub", "eP4 Synergy", "eP VIPAA", "CSS Blaze", "eP ASA", "CTMT - CDS", "CTMT - KTC", "CTMT - DAF", "CGW - authGateway", "CGW - eCommerceGW", "BCT Gateway", "eP POE", "Brainiac Studio" ];
  var ctypes = [ 
        { name: "Pilot DML", type: "DML"}, 
        { name: "Ear", type: "WS"}, 
        { name: "Dynamic DML", type: "DML"}, 
        { name: "Web Assets", type: "SA"},
        { name: "Jars", type: "SA" },
        { name: "Properties", type: "SA"},
        { name: "Artifacts", type: "SA"},
        { name: "Config", type: "SA"},
        { name: "Xml", type: "SA"} ];
  var detail = { WS: [ 
"Create:\nMember: John Ribera (NBKI812)\nRole: Developer\n", "Create:\nEnviroment: DEV01\nServer: ldranql05\nApp Name:APP"], SA: [
"Create:\nMember: Kool Breexe (NBKK00L)\nRole: Manager\n", "Create:\nEnviroment: CERT01\nServer: ldranql05.chp.bankofamerica.com\nBase Artifact Install Dir:\n/hosting/apps/udeploy\n"], DML: [ "Create:\nMember: ARandom Name\nRole: Lead Developer\n", "Environment: SIT02\nDML Env Name: E3SIT02"]
  };
  var supTypes = [ "BS", "DS", "BO", "DO" ];
  console.log("Generating a random open ticket");
  var ai = getRandIdx( apps.length );
  var ct = getRandIdx( ctypes.length );
  var st = getRandIdx( supTypes.length );
  
  console.log("Got random app #" + ai + " and random component #" + ct);
  var ot = { ts: +Date.now(), class: "id-" + ++otcid, app: apps[ai], cmp: ctypes[ct].name, detail: detail[ctypes[ct].type], status: "Open", st: supTypes[st], ae: null};
  addElement(ot, uls.head, openTickets);
  console.log("added ticket " + ot.class + ": " + ot.app + ", " + ot.cmp);
  var addAESecs = getRandIdx(5)+5;
  setTimeout(assnTicket, addAESecs * 1000);
}
/* assign an avaialable ticket */
var retryMs = 1000;
function assnTicket() {
  var aes = [ "Justin", "Trey", "Surinder", "Saravanan", "Shailza", "Billy", "Kevin", "John", "Keith", "David", "Mankind", "Waldo", "Tegrat", "Mr Fubar" ]; 
  var olderOpen = _(openTickets).filter( function(e) { (+Date.now() - e.ts) > retryMs } );
  if (olderOpen.length < 1)  {
    console.log("No tickets more than " + retryMs + "ms old");
    return setTimeout(assnTicket, retryMs);  
  }
  aei = getRandIdx(aes.length);
  console.log("Assiging random ticket to randome AE");
  console.log("Selected random AE: " + aes[aei]);
  oti = getRandIdx(openTickets.length);
  cid = openTickets[oti].class
  console.log("Assigning ticket @" + oti + " with id of " + cid + " to " + aes[aei]);
  if ((ot = removeElement(cid, uls.head, openTickets))) {
    console.log("Succefully removed openTicket " + ot);
    ot.ae = aes[aei];
    ot.status =  "In Progress";
    console.log("Assigning AE:" + ot.ae);
    addElement(ot, uls.top, aeTickets); 
    setTimeout(assignedMax, 5000);
  }
}
function assignedMax() {
  while (aeTickets.length > maxAssigned)
    removeElement(aeTickets[aeTickets.length-1].class, uls.top, aeTickets);
}
function getRandIdx(len) {
  var exp = Math.log(len);
  exp = exp < 1 ? 1 : Math.floor(exp);
  var mult = Math.pow(10, exp);
  rand = Math.floor(Math.random()*mult) % len;
  console.log("Rand(" + len + ") -> " + rand);
  return rand;
}

var notify = window.notify
var perms = null;
function checkReqNotify() {
	console.log("After require notify: " + notify);
	if (!notify) return;	
	perms = notify.permissionLevel();
	console.log("perms are initially " + perms);
	if (perms !== notify.PERMISSION_GRANTED)
		perms = notify.requestPermission( function(){ console.log("Permission Granted");}) 
console.log("Perms after are " + perms)
}
