"use strict"
console.log "$Id: api.coffee 16 2014-10-17 16:06:45Z nbki8qq $"
console.log "Loaded #{__dirname}/#{__filename}: URL: #{document.URL}"
$("td[role='gridcell']", 'body').addBack().contents().filter(-> @nodeType is 3).each -> console.log "text: #{@data}"

# vim:se expandtab ts=2:
