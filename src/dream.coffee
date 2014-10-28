"use strict"

console.log "$Id: dream.coffee 16 2014-10-17 16:06:45Z nbki8qq $"
console.log "Loaded #{__dirname}/#{__filename}: URL: #{document.URL}"

injectJs = () ->
	s = document.createElement 'script'
	s.src = chrome.extension.getURL 'script.js'
	(document.head||document.documentElement).appendChild s
	s.onload = -> s.parentNode.removeChild s

getGridValues = () ->
	$('td[role="gridcell"]', 'body').contents().filter(-> @nodeType is 3 && !/\A\s*\Z/.test @nodeValue).each -> console.log "#{@data}"

# vim:se expandtab ts=2:
