"use strict"

console.log "$Id: dream.coffee 537 2014-10-29 09:28:11Z knoppix $"
console.log "Loaded #{__dirname}/#{__filename}: URL: #{document.URL}"

injectJs = () ->
  s = document.createElement 'script'
  s.src = chrome.extension.getURL 'script.js'
  (document.head||document.documentElement).appendChild s
  s.onload = -> s.parentNode.removeChild s

getGridValues = () ->
  $('td[role="gridcell"]', 'body').contents().filter(-> @nodeType is 3 && !/\A\s*\Z/.test @nodeValue).each -> console.log "#{@data}"

# vim:se expandtab ts=2:
