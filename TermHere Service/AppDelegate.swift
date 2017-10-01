//
//  AppDelegate.swift
//  TermHere
//
//  Created by Adam Demasi on 22/11/16.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa

extension NSPasteboard.PasteboardType {
	
	static let filename = NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")
	
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationWillFinishLaunching(_ notification: Notification) {
		let app = NSApplication.shared
		
		print("oooooooo " + [
			NSPasteboard.PasteboardType(rawValue: "NSStringPboardType"),
			NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType"),
			NSPasteboard.PasteboardType(rawValue: "NSURLPboardType"),
			NSPasteboard.PasteboardType(rawValue: "NSMultipleTextSelectionPboardType")
			].debugDescription)

		// register ourself
		if #available(macOS 10.13, *) {
			app.registerServicesMenuSendTypes([
				.string,
				.filename,
				.fileURL,
				.multipleTextSelection
			], returnTypes: [])
		} else {
			app.registerServicesMenuSendTypes([
				NSPasteboard.PasteboardType(rawValue: "NSStringPboardType"),
				NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType"),
				NSPasteboard.PasteboardType(rawValue: "NSURLPboardType"),
				NSPasteboard.PasteboardType(rawValue: "NSMultipleTextSelectionPboardType")
			], returnTypes: [])
		}

		// force a refresh so our service is known
		NSUpdateDynamicServices()
	}

}
