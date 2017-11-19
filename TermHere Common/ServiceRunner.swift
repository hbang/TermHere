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
	
	class func serviceName(forAppURL appURL: URL, fallbackAppURL: URL, fallbackService: String) -> String {
		// get the bundle for the user specified app, or our fallback if necessary
		guard let bundle = Bundle(url: appURL) ?? Bundle(url: fallbackAppURL) else {
			fatalError("specified app and fallback app not found!")
		}
		
		return serviceName(forBundle: bundle) ?? fallbackService
	}
	
	class func serviceName(forBundle bundle: Bundle) -> String? {
		let activationType = Preferences.sharedInstance.terminalActivationType
		var serviceName: String? = nil
		
		// if we’re aware of a service we can directly use, we definitely want to use that. otherwise
		// we’re stuck trying a url open via NSWorkspace
		if bundle.bundleIdentifier! == "com.apple.Terminal" {
			switch activationType {
			case .newTab, .sameTab:
				serviceName = "New Terminal Tab at Folder"
				break
				
			case .newWindow:
				serviceName = "New Terminal at Folder"
				break
			}
		} else if bundle.bundleIdentifier! == "com.googlecode.iterm2" {
			switch activationType {
			case .newTab, .sameTab:
				serviceName = "New iTerm2 Tab Here"
				break
				
			case .newWindow:
				serviceName = "New iTerm2 Window Here"
				break
			}
		}
		
		return serviceName
	}
	
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
