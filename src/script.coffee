#"use strict"
console.log "$Id$"
console.log "Loaded #{__dirname}/#{__filename}: URL: #{document.URL}"
#s = document.createElement 'script'
#s.src = chrome.extension.getURL 'script.js'
#(document.head||document.documentElement).appendChild s
#s.onload = -> s.parentNode.removeChild s
# this will be executed in the context of the script

#notify = require "../vendor/desktop-notify.js"
notify = window.notify
console.log "After require notify: #{notify}"
perms = notify.permissionLevel()
console.log "perms are initially #{perms}"
perms = notify.requestPermission(-> console.log "Permission Granted") if perms isnt notify.PERMISSION_GRANTED
console.log "Perms after are #{perms}"
