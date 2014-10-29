// #(@)$Id: background.js 538 2014-10-29 09:29:33Z knoppix $
console.log( 'Background.html starting!' );
	/*Make page action icon available to all tabs  */
	chrome.tabs.onUpdated.addListener(function(tabId) {
		chrome.pageAction.show(tabId);
	});

	chrome.tabs.getSelected(null, function(tab) {
		chrome.pageAction.show(tab.id);
	});
	
	/*Send request to current tab when page action is clicked*/
	chrome.pageAction.onClicked.addListener(function(tab) {
		chrome.tabs.getSelected( null, function(tab) {
			chrome.tabs.sendRequest(
				tab.id, //Selected tab id
				{callFunction: "toggleSB"}, 
				function(response) { console.log(response); }
			);
			
		});
	});
console.log( 'Background.html done.' );
