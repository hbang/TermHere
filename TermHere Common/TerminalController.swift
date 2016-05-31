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
		let finalURLs = urlsToOpen(urls)
		let preferences = Preferences.sharedInstance

		// determine the bundle id, falling back to terminal as default
		let bundleIdentifier = preferences.terminalBundleIdentifier

		// if we don’t know any applescript for the app or it failed for some
		// reason, fall back to a standard URL open
		if !NSWorkspace.sharedWorkspace().openURLs(finalURLs, withAppBundleIdentifier: bundleIdentifier, options: .Default, additionalEventParamDescriptor: nil, launchIdentifiers: nil) {
			return false
		}

		return true
	}

	class func isDirectory(url: NSURL) -> Bool {
		var value: AnyObject?

		do {
			// is it a directory?
			try url.getResourceValue(&value, forKey: NSURLIsDirectoryKey)

			if let result = value as? NSNumber {
				return result.boolValue
			}
		} catch {
			NSLog("error while checking if %@ is a directory: %@", url, error as NSError)
		}

		// we’ll just take a risk and say yes
		return true
	}

	class func urlsToOpen(urls: [NSURL]) -> [NSURL] {
		// if the url is a file, use its parent directory
		let dirs = urls.map { isDirectory($0) ? $0 : $0.URLByDeletingLastPathComponent! }

		// filter out uniques, sort, and return
		return Array(Set(dirs)).sort { $0.absoluteString < $1.absoluteString }
	}

}
