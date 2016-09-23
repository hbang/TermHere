//
//  TerminalController.swift
//  TermHere
//
//  Created by Adam Demasi on 31/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Foundation
import Cocoa

open class TerminalController {

	open class func launch(_ urls: [URL]) -> Bool {
		let finalURLs = urlsToOpen(urls)
		let preferences = Preferences.sharedInstance

		// determine the bundle id, falling back to terminal as default
		let bundleIdentifier = preferences.terminalBundleIdentifier

		// if we don’t know any applescript for the app or it failed for some
		// reason, fall back to a standard URL open
		if !NSWorkspace.shared().open(finalURLs, withAppBundleIdentifier: bundleIdentifier, options: .default, additionalEventParamDescriptor: nil, launchIdentifiers: nil) {
			return false
		}

		return true
	}

	class func isDirectory(_ url: URL) -> Bool {
		do {
			// is it a directory?
			let values = try url.resourceValues(forKeys: [ .isDirectoryKey ])

			// if it worked, return the result
			return values.isDirectory!
		} catch {
			NSLog("error while checking if \(url) is a directory: \(error)")
		}

		// we’ll just take a risk and say yes
		return true
	}

	class func urlsToOpen(_ urls: [URL]) -> [URL] {
		// if the url is a file, use its parent directory
		let dirs = urls.map { isDirectory($0) ? $0 : $0.deletingLastPathComponent() }

		// filter out uniques, sort, and return
		return Array(Set(dirs)).sorted { $0.absoluteString < $1.absoluteString }
	}

}
