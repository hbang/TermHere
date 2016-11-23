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

	func launchTerminal(_ pasteboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
		// get the selected filenames
		guard let filenames = pasteboard.propertyList(forType: NSFilenamesPboardType) as? [String] else {
			// nothing? huh. ok
			error.pointee = "No files provided"
			return
		}

		// map the filename strings to urls
		let urls = filenames.map { URL(fileURLWithPath: $0) }

		// hop over to the main queue
		DispatchQueue.main.async {
			// launch them!
			if !TerminalController.launch(urls) {
				// if it failed, show an alert accordingly
				error.pointee = NSLocalizedString("OPENING_APP_FAILED", comment: "Message displayed when the app fails to be opened.") as NSString?

				let alert = NSAlert()
				alert.messageText = error.pointee as! String
				alert.runModal()
			}
		}
	}

}
