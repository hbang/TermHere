//
//  TerminalController.swift
//  TermHere
//
//  Created by Adam Demasi on 31/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa
import Carbon

open class TerminalController: NSObject {

	open class func launch(urls: [URL], withAppURL appURL: URL, fallbackAppURL: URL, retryIfNeeded: Bool = true) throws {
		let finalURLs = urlsToOpen(urls)
		
		// get the bundle for the user specified app, or our fallback if necessary
		guard let bundle = Bundle(url: appURL) ?? Bundle(url: fallbackAppURL) else {
			fatalError("specified app and fallback app not found!")
		}
		
		let service = ServiceRunner.serviceName(forBundle: bundle)
		
		if service != nil {
			NSLog("opening \(finalURLs) using service \(service!)")
			
			// run, and if it succeeds, we can return
			if ServiceRunner.run(service: service!, withFileURLs: finalURLs) {
				return
			}
		}

		// if we don’t know any service for the app or it failed for some reason, fall back to a
		// standard URL open
		NSLog("opening \(finalURLs) using \(bundle.bundleIdentifier!)")
		
		do {
			// try just directly opening it first
			try NSWorkspace.shared.open(finalURLs, withApplicationAt: bundle.bundleURL, options: .default, configuration: [:])
		} catch {
			let nserror = error as NSError
			let underlyingError = nserror.userInfo[NSUnderlyingErrorKey] as? NSError ?? NSError()
			
			// if it fails, check if the error is due to permissions. if so, we have to do our workaround
			if nserror.domain == NSCocoaErrorDomain && underlyingError.domain == NSOSStatusErrorDomain
				&& underlyingError.code == permErr && retryIfNeeded == true {
				// do the open panel permission routine thingy, then try calling ourself again ensuring we
				// specify not to retry again which would cause an infinite loop
				let bookmarks = SandboxController.getBookmarks(urls: urls)
				bookmarks.forEach { (url) in
					if !url.startAccessingSecurityScopedResource() {
						NSLog("failed to get access to \(url)")
					}
				}
				
				try launch(urls: bookmarks, withAppURL: appURL, fallbackAppURL: fallbackAppURL, retryIfNeeded: false)
				
				// sorta cheating, not sure what’s going on at the moment really
				bookmarks.forEach { (url) in
					let nsurl = url as NSURL
					_ = Timer.scheduledTimer(timeInterval: 5, target: nsurl, selector: #selector(nsurl.stopAccessingSecurityScopedResource), userInfo: nil, repeats: false)
				}
			} else {
				NSLog("failed to open: \(error)")
				throw error
			}
		}
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
		let dirs = urls.map { isDirectory($0) ? $0 : URL(fileURLWithPath: $0.deletingLastPathComponent().path, isDirectory: true) }

		// filter out uniques, sort, and return
		return Array(Set(dirs)).sorted { $0.absoluteString < $1.absoluteString }
	}

	// (not currently used)
	class func command(for url: URL) -> String {
		// start with the path
		var command = url.path

		// escape it like a shell argument
		command.escapeShellArgument()

		// if the url is a directory, we need to turn this into a cd command
		if isDirectory(url) {
			command = "cd \(command)"
		}

		// return the final value
		return command
	}

}
