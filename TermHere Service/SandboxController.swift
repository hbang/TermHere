//
//  SandboxController.swift
//  TermHere
//
//  Created by Adam Demasi on 19/11/17.
//  Copyright © 2017 HASHBANG Productions. All rights reserved.
//

import Cocoa

fileprivate struct Bookmark {
	
	var url: URL!
	var isStale: Bool = false
	
}

class SandboxController {
	
	class func getBookmarks(urls: [URL]) -> [URL] {
		var finalURLs: [URL] = []
		
		for url in urls {
			if let bookmark = bookmarkForURL(url) {
				finalURLs.append(bookmark.url)
				
				// if the bookmark is stale, the system wants us to grab another bookmark to be used the
				// next time we need it. however, it seems we’re still meant to use the old stale bookmark
				// this one last time?
				if bookmark.isStale {
					storeBookmarkForURL(url, broadURL: broadestBookmarkURLForURL(url), force: true)
				}
			} else {
				let broadURL = broadestBookmarkURLForURL(url)
				
				let openPanel = NSOpenPanel()
				openPanel.canChooseDirectories = true
				openPanel.canChooseFiles = false
				openPanel.directoryURL = broadURL
				
				let accessoryView = OpenPanelAccessoryViewController()
				openPanel.accessoryView = accessoryView.view
				
				accessoryView.label.stringValue = String(format: NSLocalizedString("GRANT_SANDBOX_PERMISSION_MESSAGE", comment: "Message displayed in a file open panel asking the user to give permission to read the folder. %@ is the folder path."), broadURL.path)
				
				if #available(OSX 10.11, *) {
					// ensure the accessory view is already open. it’s always open earlier than elcap
					openPanel.isAccessoryViewDisclosed = true
				}
				
				// runModal() is synchronous, love it or hate it
				openPanel.runModal()
				
				// this lets us now get a permanent bookmark to this URL
				storeBookmarkForURL(url, broadURL: broadURL)
				
				// and finally we can safely add the url
				finalURLs.append(url)
			}
		}
		
		return finalURLs
	}
	
	private class func broadestBookmarkURLForURL(_ url: URL) -> URL {
		// if this url is in a home directory or volume mount point, use the entire home dir/mount
		// point so we get as broad permission as possible. otherwise, just use the specific dir
		let realURL = url.resolvingSymlinksInPath()
		
		if realURL.pathComponents.count > 2 && (realURL.pathComponents[1] == "Users" || realURL.pathComponents[1] == "Volumes") {
			return URL(string: "file:///")!.appendingPathComponent(realURL.pathComponents[1]).appendingPathComponent(realURL.pathComponents[2])
		} else {
			// ensure we’re only inserting directories, not files
			return TerminalController.isDirectory(realURL) ? realURL : realURL.deletingLastPathComponent()
		}
	}
	
	private class func bookmarkForURL(_ url: URL) -> Bookmark? {
		let bookmarks = Preferences.sharedInstance.sandboxBookmarks
		let broadURL = broadestBookmarkURLForURL(url)
		
		if let data = bookmarks[broadURL.path] {
			do {
				var isStale: Bool = false
				_ = try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
			
				var bookmark = Bookmark()
				bookmark.url = url
				bookmark.isStale = isStale
				return bookmark
			} catch {
				NSLog("getting bookmark for url \(url) failed: \(error)")
			}
		}
		
		return nil
	}
	
	private class func storeBookmarkForURL(_ url: URL, broadURL: URL, force: Bool = false) {
		var bookmarks = Preferences.sharedInstance.sandboxBookmarks
		
		if bookmarks[broadURL.path] != nil && !force {
			// nothing to do
			return
		}
		
		do {
			let data = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: [ .isDirectoryKey ], relativeTo: nil)
			bookmarks[broadURL.path] = data
			Preferences.sharedInstance.sandboxBookmarks = bookmarks
		} catch {
			NSLog("storing bookmark for url \(url) failed: \(error)")
		}
	}
	
}
