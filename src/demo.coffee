#  vim:expandtab:ts=2:
# @(#) $Id: demo.coffee 543 2014-11-05 00:41:31Z knoppix $
$ = jQuery
# Handle requests from background.html
console.log "Loading $Id: demo.coffee 543 2014-11-05 00:41:31Z knoppix $"
console.log "Initializing %0", this
handleRequest = (request, sender, sendResponse) ->
  console.log "got request #{request.callFunction}"
  toggleSB() if request?.callFunction is "toggleSB"

chrome.extension.onRequest.addListener handleRequest
# Create the sidebar - ToDo: Use a config object as args to callSB
sidebarPrev = true           # prev state true means current is false
[openTickets, aeTickets]     = [[], []]
[genIvl, genIvlId, me]       = [5, null, "John"]
[lists, otId, maxAsn]        = [{head: {}, top: {}}, 0, 5]
sbId = "mySidebar"

# undo createSB()
destroySB  = ->
  console.log "disabling sidebar and genIvl: #{genIvl}"
  genIvlId? and clearInterval genIvlId
  el = document.getElementById sbId
  return el.parentNode.removeChild el

# create sidebar()
createSB = ->
  navBar         = """
<div class="navbar navbar-custom">
  <div class="navbar-inner">
    <a class="brand" href="#">JJR@DevOps</a>
    <ul class="nav">
      <li class="active"><a href="#">Open</a></li>
      <li><a href="#">Servers</a></li>
      <li><a href="#">Users</a></li>
      <li><a href="#">Perms</a>
    </ul>
  </div>
</div>"""
  # Start of Lists
  lists.head.id    = "listHead"
  lists.head.html  = """
<div id="#{lists.head.id}">
    <h4>Open Requests <span class="badge">#{openTickets.length}</span></h1>
    <ul class="nav-list"></ul>
</div>
"""
  lists.top.id    = "listTop"
  lists.top.html  = """
<div id="#{lists.top.id}">
  <h4>Assigned Requests <span class="badge">#{aeTickets.length}</span></h4>
  <ul class="nav-list"></ul>
</div>
"""
  #var sbNav ='<button class="btn", id="servers">Servers</button>' +
  #  '<button class="btn", id="users">Users</button>'
  sbMain            = '<div> <ul id="sbMain"> </ul> <div>'
  sidebar           = document.createElement 'div'
  sidebar.id        = sbId
  sidebar.style.display = 'hide'
  sidebar.innerHTML ="""
#{navBar}
#{lists.head.html}
#{lists.top.html}
#{sbMain}
"""
  document.body.appendChild sidebar
  console.log "sidebar div added."

  for name in ["head", "top"]
    for tag in [ "ul", "span"]
      lists[name][tag] = $ tag, "div##{lists[name].id}"
  initLists()
# toggle and kick things off...
toggleSB = ->
  genIvlId = setInterval genTicket, genIvl * 1000 unless genIvlId?
  console.log "setting up a genTicket every #{genIvl} secs"
  if sidebarPrev = not sidebarPrev then $("##{sbId}").hide() else $("##{sbId}").show()

  console.log "enabling sidebar: checking notifications for this page"
  checkReqNotify() # ToD:o fix request perms for current page


  console.log "sidebar div added. Adding empty lists head: #{lists.head.id}, and top: #{lists.top.id}"
  createSB() if not $("##{sbId}").length
    

initLists = () ->
  once = false
  if once
    console.log "Initializing lists..."
    openTickets.forEach (e)-> insElement e, lists.head
    updCounters lists.head, openTickets.length
    aeTickets.forEach   (e)-> insElement e, lists.top
    updCounters lists.top, aeTickets.length

addElement = (el, list, ary) ->
  console.log "addEl: #{el} Before: ary: #{ary.length} to #{list.id}: #{list.ul.length}"
  ary.push el
  insElement el, list
  console.log "addEl: After: ary: #{ary.length} ul: #{list.id}: #{list.ul.length}"
  updCounters list, ary.length

title = (el) -> "#{el.st} - #{el.app} - #{el.cmp}"

createNotificationIfNotVisible = (el) ->
  nOpts     = body: el.detail, icon: "icon.png", tag: el.id
  if el.status is "Open" and document.webkitVisibilityState isnt "visible"
    el.closer = notify.createNotification "#{title el}", nOpts


insElement  = (el, list) ->
  [ae, labclass] = if el.ae then [" - #{el.ae} ", "label-info"] else ["", "label-warning active"]
  createNotificationIfNotVisible el
  html      = """<li class="#{el.id}">#{title el}: <span class="label #{labclass}"> #{el.status}#{ae}</span></li>"""
  $(html).hide().prependTo(list.ul).fadeIn 1900

removeElement = (sel, list, ary) ->
  console.log "rmEl: before: #{sel} len: #{ary.length}, ul: #{list.id}: #{list.ul.length}"
  found = _(ary).remove (e)-> e.id is sel
  if found and ret = found.value()[0]
    ret.closer.close() if ret.closer
    $("li.#{sel}", list.ul).remove()
    msg = "rmEl: after: #{ret.id} len: #{ary.length}, ul: #{list.id} (#{list.ul.length})"
    console.log msg
#    throw new Error(msg) unless list.ul.length < preRm
    updCounters list, ary.length
  else
    msg = "didnt find #{sel} in #{list.id}"
    console.log msg
    throw new Error msg
  ret
removeLast = (list, ary) ->
  console.log "remLast of #{ary.length} (#{ list.ul.length})"
  if ary.length > 0 and list.ul.length > 0
    last = ary.pop()
    if last.closer then last.closer.close()
    list.ul.last().remove()
    console.log "remLast of #{ary.length } (#{list.ul.length})"
  else
    console.log "No last element to remove"

updCounters = (list, val) -> list.span.text val

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
    SA: [ "Create:\nMember: Kool Breeze (NBKK00L)\nRole: Manager\n", "Create:\nEnviroment: CERT01\nServer: ldranql05.chp.bankofamerica.com\nBase Artifact Install Dir:\n/hosting/apps/udeploy\n"]
    DML: [ "Create:\nMember: ARandom Name\nRole: Lead Developer\n", "Environment: SIT02\nDML Env Name: E3SIT02"]

  supTypes = [ "BS", "DS", "BO", "DO" ]
  ai = getRandIdx apps.length
  ct = getRandIdx ctypes.length
  st = getRandIdx supTypes.length
  ot =
    ts: +Date.now()
    id: "id-#{++otId}"
    app: apps[ai]
    cmp: ctypes[ct].name,
    detail: detail[ctypes[ct].type]
    status: "Open"
    st: supTypes[st]
    ae: null
    toString: -> "#{@id}: #{@st} - #{@app} - #{@cmp}"

  console.log "Generated random ticket #{ot}...adding to openTickets..."
  addElement ot, lists.head, openTickets
  console.log "added ticket #{ot} to #{lists.head.id}"

  addAESecs = getRandIdx(5)+5
  setTimeout assnTicket, addAESecs * 1000

# clean up assigned tickets
cleanAssigned = ->
  while aeTickets.length > maxAsn
    removeElement aeTickets[0].id, lists.top, aeTickets

# assign an avaialable ticket
retryMs = 1000
assnTicket = ->
  aes = [ me, "Prudhvi", "Gregory", "Dan", "Hemal", "Shailza", "Billy", "John", "Jennifer", "David", "Koyt", "Waldo", "Kripa", "Amit" ]

  olderOpen= _(openTickets).filter (e) -> (+Date.now() - e.ts) > retryMs
  if olderOpen.length < 1
    console.log "No tickets more than #{retryMs}ms old"
    return setTimeout assnTicket, retryMs
  aei      = getRandIdx aes.length
  oti      = getRandIdx openTickets.length
  ot       = openTickets[oti]
  console.log "Assigning open ticket @#{oti} #{ot} to #{aes[aei]}"
  if rm    = removeElement ot.id, lists.head, openTickets
    rm.ae  = aes[aei]
    rm.status =  "Accepted"
    console.log "#{rm.ae} - #{rm.status} Ticket #{rm}"
    addElement rm, lists.top, aeTickets
    setTimeout cleanAssigned, 5000

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

