//
//  TerminalServiceProvider.swift
//  TermHere
//
//  Created by Adam Demasi on 21/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Carbon
import Cocoa
import CoreServices
import TermHereCommon

@objc(TerminalServiceProvider) class TerminalServiceProvider: NSObject {

	@objc func launchTerminal(_ pasteboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
		// of course, because swift is so wonderful and all that kinda thing, NSFilenamesPboardType was
		// taken away from us in favor of PasteboardType.fileURL. which… well… only exists as of 10.13.
		// yeah, thanks guys. work around it by just using the raw value with PasteboardType if <10.13
		// TODO: radar
		var urls: [URL]
		
		if #available(macOS 10.13, *) {
			// get the selected file names
			guard let items = pasteboard.propertyList(forType: .fileURL) as? [URL] else {
				// nothing? huh. ok
				error.pointee = "No files provided"
				return
			}
			
			urls = items
			NSLog("oooooooooo items " + urls.debugDescription)
		} else {
			// get the selected file names
			guard let items = pasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? [String] else {
				// nothing? huh. ok
				error.pointee = "No files provided"
				return
			}
			
			// map the filename strings to urls
			urls = items.map { URL(fileURLWithPath: $0) }
			NSLog("oooooooooo items " + urls.debugDescription)
		}

		// hop over to the main queue
		DispatchQueue.main.async {
			// launch them!
			if !TerminalController.launch(urls) {
				// if it failed, show an alert accordingly
				error.pointee = NSLocalizedString("OPENING_APP_FAILED", comment: "Message displayed when the app fails to be opened.") as NSString?

				let alert = NSAlert()
				alert.messageText = error.pointee! as String
				alert.runModal()
			}
		}
	}
	
	@objc func launchEditor(_ pasteboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
		error.pointee = "Nice"
	}

}
