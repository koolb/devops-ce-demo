"use strict"
console.log "#(@) $Id: api.coffee 537 2014-10-29 09:28:11Z knoppix $"
console.log "Loaded #{__dirname}/#{__filename}: URL: #{document.URL}"
$("td[role='gridcell']", 'body').addBack().contents().filter(-> @nodeType is 3).each -> console.log "text: #{@data}"

# vim:se expandtab ts=2:
