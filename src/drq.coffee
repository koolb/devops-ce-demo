"use strict"
console.log "$Id: drq.coffee 21 2014-10-17 16:57:26Z nbki8qq $"
console.log "Loaded #{__dirname}/#{__filename}: URL: #{document.URL}"
mm       = require 'minimongo'
cheerio  = require 'cheerio'
_        = require 'lodash'
request  = require 'superagent'
console.log "Loaded #{__dirname}/#{__filename}: URL: #{document.URL}"
# IndexedDb = mm.IndexedDb
url = '/RequestQueue/FindRequestAggregations'
#db = new IndexedDb namespace: "dream", ()->
#  db.addCollection "dream"
#  db.dream.findOne url: url, {},  (doc) ->
#    if (doc) then console.log "found: #{url} with #{doc.data.length} entries"
#    else
#request.post(url)
#  .type("form")
#  .send("sort=")
#  .send("group=")
#  .send("filter=")
#  .send("statusIds[0]=8")
#  .send("statusIds[1]=16")
#  .send("statusIds[2]=17")
#  .send("statusIds[3]=19")
#  .end  (err, res)->
#    throw err if err?
#    console.log "Got: res"
#    reqs = res.body.Data
##    db.dream.upsert url: url, data: res.body.Data, uts: Date.now()
#    console.log "inserted #reqs: #{reqs.length}"
#    console.log "Done."
$('body').contents().filter(-> @nodeType is 3).each ->
  console.log "#{@data}"

notify = window.notify
console.log "Window.notify is #{notify}"
perms = notify.permissionLevel()
console.log "Permission level is initially #{perms}"

paused = false
$('.jnt-play-pause', 'body').click (e) ->
  paused = !paused
  console.log "Clicked: paused is #{paused}"

if paused
  console.log "Not paused..."
  a2m = document.getElementById "quick-filter-assignedtome"
  console.log "Element a2m: #{a2m}"
  a2m.style.backgroundColor = "red"




#/*
#  $ = cheerio.load res.text
#  body = $('body').text()
#  console.log "got: #{body}"
#  inps = $('input')
#  ninps = inps.length
#  console.log "inps: #{ninps}"
#  divs = $('.btn-grid-action')
#  ndivs = divs.length
#  console.log "divs: #{ndivs}"
#  inps.each  () -> console.log "inp: #{$(this).text()}"
#  divs.each  () -> console.log "div: #{$(this).html()}"
#*/

# vim:se expandtab ts=2:
