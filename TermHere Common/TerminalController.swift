//
//  TerminalController.swift
//  TermHere
//
//  Created by Adam Demasi on 31/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Foundation
import Cocoa

public class TerminalController {

	public class func launch(urls: [NSURL]) -> Bool {
		let preferences = Preferences.sharedInstance

		// determine the bundle id, falling back to terminal as default
		let bundleIdentifier = preferences.terminalBundleIdentifier

		// if we don’t know any applescript for the app or it failed for some
		// reason, fall back to a standard URL open
		if !NSWorkspace.sharedWorkspace().openURLs(urls, withAppBundleIdentifier: bundleIdentifier, options: .Default, additionalEventParamDescriptor: nil, launchIdentifiers: nil) {
			return false
		}

		return true
	}

}
