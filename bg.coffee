# vim: se ts=2 expandtab:
# #(@)$Id$
# @author: koolb@hotmail.com
# @description: Demo/fake sidepanel updater
# @usage: click on open items to see content and check to make it mine!
#
# @release state: alpha testing only many functions do not yet exist
#
console.log 'bg.html starting!'
chrome.tabs.onUpdated.addListener (tabId) -> chrome.pageAction.show tabId
chrome.tabs.getSelected null, (tab) -> chrome.pageAction.show tab.id
chrome.pageAction.onClicked.addListener (tab) -> chrome.tabs.getSelected null, (tab) ->
	chrome.tabs.sendRequest tab.id, {callFunction: "toggleSB"}, (response) -> console.log response
console.log 'bg.html done.'
