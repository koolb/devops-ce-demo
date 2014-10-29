#  vim:expandtab:ts=2:
# @(#) $Id$
$ = jQuery
# Handle requests from background.html

handleRequest = (request, sender, sendResponse) -> request[callFunction]() if request?.callFunction
chrome.extension.onRequest.addListener handleRequest
  
# Create the sidebar
sidebarOpen = false
cssInjected = false
openTickets = []
aeTickets   = []
genIvl      = 5
genIvlId    = null
openCnt     = null
uls         = {}
otcid       = 1
maxAssigned = 5
# toggle and kick things off...
toggleSB = ->
  if sidebarOpen
    console.log "disabling sidebar and genIvl: #{genIvl}"
    genIvlId? and clearInterval genIvlId
    el = document.getElementById 'mySidebar'
    el.parentNode.removeChild el
  else
    console.log "checking notifications for this page"
    checkReqNotify()
    console.log "adding div"

    navBar         = '<div class="navbar navbar-custom"><div class="navbar-inner"><a class="brand" href="#">JJR@DevOps</a><ul class="nav"><li class="active"><a href="#">Open</a></li><li><a href="#">Servers</a></li><li><a href="#">Users</a></li><li><a href="#">Perms</a></ul></div></div>'

    sbListHead         = '<div><h4>Open Requests <span class="badge openCnt">0</span></h1><ul class="nav-list" id="listHead"></ul></div>'

    sbListTop         = '<div><h4>Assigned Requests (Accepted: <span class="badge acceptCnt">1</span>)</h4><ul id="listTop" class="nav-list"></ul></div>'

    #var sbNav ='<button class="btn", id="servers">Servers</button>' +
    #  '<button class="btn", id="users">Users</button>'
    sbMain = '<div> <ul id="contentMain"> </ul> <div>'
    sidebar = document.createElement 'div'
    sidebar.id        = "mySidebar"
    sidebar.class     = "mysidebar"
    sidebar.innerHTML ="#{navBar}\n#{sbListHead}\n#{sbListTop}]\n#{sbMain}"
    document.body.appendChild sidebar

    sbMain            = '<div> <ul id="sbMain"> </ul> <div>'
    sidebar           = document.createElement 'div'
    console.log "sidebar div added. Adding empty lists"
    uls               = head: $("#listHead"), top: $("#listTop")
    console.log "sidebar div added. Adding empty lists head: #{uls.head}, and top: #{uls.top}"
    console.log "setting up a genTicket every #{genIvl} secs"
    genIvlId          = setInterval genTicket, genIvl * 1000
    initLists()
  sidebarOpen = !sidebarOpen

initLists = () ->
  console.log "Initializing lists..."
  openTickets.forEach (e)-> insElement e, uls.head
  aeTickets.forEach   (e)-> insElement e, uls.top

addElement = (el, ul, ary) ->
  ary.push el
  console.log "Adding at ticket for #{el.class}"
  insElement el, ul
  updCounters ul

insElement  = (el, ul) ->
  console.log "insEl: #{el.class}"
  labclass  = "label-info"
  ae        = if el.ae then " - #{el.ae}: " else el.ae
  nTitle    = "#{el.st} - #{el.app} - #{el.cmp}"
  nOpts     = body: el.detail, icon: "icon.png", tag: el.class
  if el.status is "Open" and document.webkitVisibilityState isnt "visible"
    el.closer = notify.createNotification nTitle, nOpts
  labclass  = "label-warning active"
  html      = "<li class=\"#{el.class}\">#{nTitle}: <span class=\"label #{labclass}\"> #{el.status} - #{ae}</span></li>"
  $(html).hide().prependTo(ul).fadeIn 900
#  console.log "insEl: after ul.append: ul.length is: #{ul.length}"

removeElement = (sel, ul, ary) ->
  ret   = null
  console.log "remEl: #{sel} of #{ul.length}"
  console.dir ul
  found = _(ary).find (e)-> e.class is sel
  if found.length
    ret = ary.splice(found, 1)[0]
    ret.closer.close() if ret.closer
    console.log "found #{found}: #{ret}"
    $(ul.find "li.#{sel}").remove()
    updCounters ul
  else
    console.log "didnt find #{sel} in #{ul}"
  ret
removeLast = (ul, ary) ->
  console.log "remLast of #{ary.length} (#{ ul.length})"
  if ary.length > 0 and ul.length > 0
    last = ary.pop()
    if last.closer then last.closer.close()
    ul.last().remove()
    console.log "remLast of #{ary.length } (#{ul.length})"
  else
    console.log "No last element to remove"

updCounters = (ul) ->
  if !openCnt then openCnt = $(".openCnt")
  openCnt.text(openTickets.length)

genTicket = ->
  apps = [ "eP AuthHub", "eP4 Synergy", "eP VIPAA", "CSS Blaze", "eP ASA", "CTMT - CDS", "CTMT - KTC", "CTMT - DAF", "CGW - authGateway", "CGW - eCommerceGW", "BCT Gateway", "eP POE", "Brainiac Studio" ]
  ctypes = [
        {name: "Pilot DML", type: "DML"}
        {name: "Ear", type: "WS"}
        {name: "Dynamic DML", type: "DML"}
        {name: "Web Assets", type: "SA"}
        {name: "Jars", type: "SA"}
        {name: "Properties", type: "SA"}
        {name: "Artifacts", type: "SA"}
        {name: "Config", type: "SA"}
        {name: "Xml", type: "SA"}
  ]
  detail =
    WS: [ "Create:\nMember: John Ribera (NBKI812)\nRole: Developer\n", "Create:\nEnviroment: DEV01\nServer: ldranql05\nApp Name:APP"]
    SA: [ "Create:\nMember: Kool Breexe (NBKK00L)\nRole: Manager\n", "Create:\nEnviroment: CERT01\nServer: ldranql05.chp.bankofamerica.com\nBase Artifact Install Dir:\n/hosting/apps/udeploy\n"]
    DML: [ "Create:\nMember: ARandom Name\nRole: Lead Developer\n", "Environment: SIT02\nDML Env Name: E3SIT02"]

  supTypes = [ "BS", "DS", "BO", "DO" ]
  console.log "Generating a random open ticket"
  ai = getRandIdx apps.length
  ct = getRandIdx ctypes.length
  st = getRandIdx supTypes.length

  console.log "Got random app # #{ai} and random component # #{ct}"
  ot = ts: +Date.now()
  class: "id-" + ++otcid
  app: apps[ai]
  cmp: ctypes[ct].name,
  detail: detail[ctypes[ct].type]
  status: "Open"
  st: supTypes[st]
  ae: null

  addElement ot, uls.head, openTickets
  console.log "added ticket #{ot.class}: #{ot.appx}, #{ot.cmp}"

  addAESecs = getRandIdx(5)+5
  setTimeout assnTicket, addAESecs * 1000

# assign an avaialable ticket
retryMs = 1000
assnTicket = ->
  aes = [ "Justin", "Trey", "Surinder", "Saravanan", "Shailza", "Billy", "Kevin", "John", "Keith", "David", "Mankind", "Waldo", "Tegrat", "Mr Fubar" ]

  olderOpen = _(openTickets).filter (e) -> (+Date.now() - e.ts) > retryMs

  if olderOpen.length < 1
    console.log "No tickets more than #{retryMs}ms old"
    return setTimeout assnTicket, retryMs

  aei = getRandIdx aes.length
  console.log "Assigned random ticket to randome AE: #{aes[aei]}"
  oti = getRandIdx openTickets.length
  cid = openTickets[oti].class
  console.log "Assigning ticket @#{oti} with id of #{cid} to #{aes[aei]}"
  if ot = removeElement cid, uls.head, openTickets
    console.log "Succefully removed openTicket #{ot}"
    ot.ae = aes[aei]
    ot.status =  "In Progress"
    console.log "Assigning AE: #{ot.ae}"
    addElement ot, uls.top, aeTickets
    setTimeout assignedClean, 5000

assignedClean ->
  while aeTickets.length > maxAssigned
    removeElement aeTickets[0].class, uls.top, aeTickets

getRandIdx = (len) ->
  exp = Math.log len
  exp = if exp < 1 then 1 else Math.floor exp
  mult = Math.pow 10, exp
  rand = Math.floor(Math.random()*mult) % len

notify = @notify # was window.notify
perms = null
checkReqNotify = ->
  console.log "After require notify: #{notify}"
  return unless notify
  perms = notify.permissionLevel()
  console.log "perms are initially #{perms}"
  if perms isnt notify.PERMISSION_GRANTED
    perms = notify.requestPermission -> console.log "Permission Granted"
  console.log "Perms after are #{perms}"

