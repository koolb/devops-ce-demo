#(@)$Id$
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
	}
	else {
		if (!cssInjected) {
			console.log("adding css/styles.css");
			var link = document.createElement("link");
			link.href = chrome.extension.getURL("css/styles.css");
			link.type = "text/css";
			link.rel = "stylesheet";
			document.getElementsByTagName("head")[0].appendChild(link);
		}

		console.log("adding div");
		var navBar = '<div class="navbar"><div class="navbar-inner"><a class="brand" href="#">JJR@DevOps</a><ul class="nav"><li class="active"><a href="#">Open</a></li><li><a href="#">Servers</a></li><li><a href="#">Users</a></li></ul></div></div>';
                var sbListHead = '<div><h4>Open Requests <span class="badge openCnt">0</span></h1><ul class="nav-list" id="listHead"></ul></div>';
                var sbListTop = '<div><h4>Assigned Requests</h4><ul id="listTop" class="nav-list"></ul></div>';
		var sbNav='<button class="btn", id="servers">Servers</button>' +
			'<button class="btn", id="users">Users</button>';
		var sbContentMain = '<div> <ul id="contentMain"> </ul> <div>';
		var sidebar = document.createElement('div');
		sidebar.id = "mySidebar";
		sidebar.class = "mysidebar";
		sidebar.innerHTML = navBar +sbListHead + sbListTop + sbNav+ sbContentMain;
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
	openTickets.forEach( function(e) { createElement(e, uls.head) });
	aeTickets.forEach( function(e) { createElement(e, uls.top) } );
}
function addElement(el, ul, ary) {
	ary.push(el);
	console.log("Adding at ticket for " + el.class);
	createElement(el, ul);
	updCounters(ul);
}
function createElement(el, ul) {
	console.log("createEl: " + el.class);
	var labclass = "label-info";
	var ae = el.ae ? "(" + el.ae + ")" : "";
	if (el.status == "Open") {
		labclass = "label-warning active";
	}
	ul.append( '<li class="' + el.class + '">' + el.app + ' - ' + el.cmp + ': <span class="label ' + labclass + '">' + el.status + '</span>' + ae + '</li>');
	console.log("createEl: after ul.append: ul.length is: " + ul.length);
}
function findElement(sel, ary) {
	console.log("findEl: " + sel + " + ary.length");
	for (var i in ary) if (ary[i].class === sel) return i;
	console.log("findEl: did not find " + sel);
}
function removeElement(sel, ul, ary) {
	console.log("remEl: " + sel + " of " + ul.length);
	console.dir(ul);
	var found = findElement(sel, ary);
	if (found) {
		var ret = ary.splice(found, 1)[0];
		console.log("found " + found + ":" + ret);
		$(ul.find("li." + sel)).remove();
		updCounters(ul);
		return ret;
	} else {
		console.log("didnt find " + sel  + " in " + ul);
	}
}
function updCounters(ul) { 
	if (!openCnt) openCnt = $(".openCnt"); 
	openCnt.text(uls.head.length); 
}
function genTicket() { 
	var apps = [ "eP AuthHub", "eP4 Synergy", "eP VIPAA", "CSS Blaze" ]
	var ctypes = [ { name: "Pilot DML", type: "DML"}, 
		          { name: "Ear", type: "WS"}, 
			  { name: "Dynamic DML", type: "DML"}, 
			  { name: "Web Assets", type: "SA"},
			  { name: "Jars", type: "SA" },
			  { name: "Properties", type: "SA"} ];
	var detail = { WS: [ 
"Create:\nMember: John Ribera (NBKI812)\nRole: Developer\n", "Create:\nEnviroment: DEV01\nServer: ldranql05\nApp Name:APP"], SA: [
"Create:\nMember: Kool Breexe (NBKK00L)\nRole: Manager\n", "Create:\nEnviroment: CERT01\nServer: ldranql05.chp.bankofamerica.com\nBase Artifact Install Dir:\n/hosting/apps/udeploy\n"], DML: [ "Create:\nMember: ARandom Name\nRole: Lead Developer\n", "Environment: SIT02\nDML Env Name: E3SIT02"]
	};
	console.log("Generating a random open ticket");
	var ai = getRandIdx( apps.length );
	var ct = getRandIdx( ctypes.length );
	console.log("Got random app #" + ai + " and random component #" + ct);
	var ot = { class: "id-" + ++otcid, app: apps[ai], cmp: ctypes[ct].name, detail: detail[ctypes[ct].type], status: "Open", ae: null};
	addElement(ot, uls.head, openTickets);
	console.log("added ticket " + ot.class + ": " + ot.app + ", " + ot.cmp);
	var addAESecs = getRandIdx(3)+4;
	setTimeout(assnTicket, addAESecs * 1000);
}
function assnTicket() {
	var aes = [ "Shailza", "Amit", "Kevin", "John", "Keith", "David", "VanGorilla", "Waldo", "Superman" ]; 
	aei = getRandIdx(aes.length);
	console.log("Assiging random ticket to randome AE");
	if (aei >= 0 && aei < aes.length)  {
		console.log("Selected random AE: " + aes[aei]);
		oti = getRandIdx(openTickets.length);
		cid = openTickets[oti].class
		console.log("Assigning ticket @" + oti + " with id of " + cid + " to " + aes[aei]);
		ot = removeElement(cid, uls.head, openTickets);
		if (ot) {
			console.log("Succefully removed openTicket " + ot);
			ot.ae = aes[aei];
			ot.status =  "In Progress";
			console.log("Assigning AE:" + ot.ae);
			addElement(ot, uls.top, aeTickets); 
			setTimeout(assignedMax, 5000);
			
		}
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

