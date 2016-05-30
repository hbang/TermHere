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

class TerminalServiceProvider: NSObject {

	func launchTerminal(pasteboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
		// immediately tell the app delegate so our dock icon is hidden
		let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
		appDelegate.appMode = .Service

		// get the selected filenames
		guard let filenames = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String] else {
			// nothing? huh. ok
			error.memory = "No files provided"
			return
		}

		// map the filename strings to urls
		let urls = filenames.map { NSURL(fileURLWithPath: $0) }

		// hop over to the main queue
		dispatch_async(dispatch_get_main_queue()) {
			// launch them!
			if !TerminalController.launch(urls) {
				// if it failed, show an alert accordingly
				error.memory = NSLocalizedString("OPENING_APP_FAILED", comment: "Message displayed when the app fails to be opened.")

				let alert = NSAlert()
				alert.messageText = error.memory as! String
				alert.runModal()
			}
		}
	}
	
}
