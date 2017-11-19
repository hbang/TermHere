//
//  ServiceRunner.swift
//  TermHere
//
//  Created by Adam Demasi on 17/11/17.
//  Copyright © 2017 HASHBANG Productions. All rights reserved.
//

import Cocoa

class ServiceRunner {
	
	fileprivate static var pasteboard: NSPasteboard = {
		let bundleIdentifier = Bundle.main.bundleIdentifier!
		return NSPasteboard(name: NSPasteboard.Name(rawValue: "\(bundleIdentifier).pasteboard"))
	}()
	
	class func run(service: String, withFileURLs fileURLs: [URL]) -> Bool {
		// completely undocumented as far as i can tell, but NSPerformService() must be called from the
		// main thread. otherwise it’ll crash when displaying error messages as an NSAlert() because it
		// doesn’t jump to the main thread before calling runModal!
		// TODO: radar
		if !Thread.isMainThread {
			fatalError("ServiceRunner.run() called from non-main thread!")
		}
		
		var pasteboardItems: [NSPasteboardItem] = []
		
		// loop over each item and create an NSPasteboardItem for it. this allows us to send all items
		// to the service in one go
		for url in fileURLs {
			let item = NSPasteboardItem()
			item.setString(url.path, forType: .compatString)
			
			pasteboardItems.append(item)
		}
		
		pasteboard.declareTypes([ .compatString ], owner: nil)
		pasteboard.writeObjects(pasteboardItems)
		
		if !NSPerformService(service, self.pasteboard) {
			NSLog("service execution failed, and we don’t know why!!")
			return false
		}
		
		return true
	}
	
}
