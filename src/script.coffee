# vim:expandtab:ts=2:
"use strict"
console.log "#(@) $Id: script.coffee 537 2014-10-29 09:28:11Z knoppix $"
console.log "Loaded #{__dirname}/#{__filename}: URL: #{document.URL}"

injectJs = ->
  s = document.createElement 'script'
  s.src = chrome.extension.getURL 'script.js'
  (document.head or document.documentElement).appendChild s
  s.onload = -> s.parentNode.removeChild s
    
# this will be executed in the context of the script

notify = window.notify
console.log "After require notify: #{notify}"
perms = notify.permissionLevel()
console.log "perms are initially #{perms}"
perms = notify.requestPermission(-> console.log "Permission Granted") if perms isnt notify.PERMISSION_GRANTED
console.log "Perms after are #{perms}"
