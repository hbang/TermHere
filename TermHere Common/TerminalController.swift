//
//  TerminalController.swift
//  TermHere
//
//  Created by Adam Demasi on 31/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Foundation
import Cocoa
import Carbon

open class TerminalController: NSObject {

	static let applescriptCommands: [String: [String: String]] = {
		let bundle = Bundle(for: TerminalController.self)
		let url = bundle.url(forResource: "AppleScriptCommands", withExtension: "plist")!
		return NSDictionary(contentsOf: url) as! [String: [String: String]]
	}()

	open class func launch(_ urls: [URL]) -> Bool {
		let finalURLs = urlsToOpen(urls)
		let preferences = Preferences.sharedInstance

		// determine the bundle id, falling back to terminal as default
		let bundleIdentifier = preferences.terminalBundleIdentifier
		let activationType = preferences.activationType

		// if the app is known, get its commands dictionary
		if let commands = TerminalController.applescriptCommands[bundleIdentifier] {
			// if the command is known, get its applescript
			if let command = commands[activationType.description] {
				// ensure the app is running by launching it. this usually would bring all of its windows to
				// the front, which is awful, so we ask it to not do that. the applescript will activate
				// just the window in question
				NSWorkspace.shared.launchApplication(withBundleIdentifier: bundleIdentifier, options: .withoutActivation, additionalEventParamDescriptor: nil, launchIdentifier: nil)

				// create an applescript object, wrapped in a function
				let applescript = NSAppleScript(source: "on runCommand(command)\n" + command + "\nend runCommand")

				var hadError = false

				// loop over urls to open
				for url in urls {
					// create our argument list
					let parameters = NSAppleEventDescriptor.list()
					parameters.insert(NSAppleEventDescriptor(string: TerminalController.command(for: url)), at: 0)

					// use this legacy api monstrosity to create an apple event that calls
					// the function for us
					let event = NSAppleEventDescriptor(eventClass: AEEventClass(UInt(kASAppleScriptSuite)), eventID: AEEventID(UInt(kASSubroutineEvent)), targetDescriptor: NSAppleEventDescriptor.null(), returnID: AEReturnID(Int(kAutoGenerateReturnID)), transactionID: AETransactionID(UInt(kAnyTransactionID)))
					event.setDescriptor(parameters, forKeyword: AEKeyword(UInt(keyDirectObject)))
					event.setDescriptor(NSAppleEventDescriptor(string: "runCommand"), forKeyword: AEKeyword(UInt(keyASSubroutineName)))

					// execute it
					var errorInfo: NSDictionary?
					applescript!.executeAppleEvent(event, error: &errorInfo)

					// if we got an error
					// executeAppleEvent() is meant to be nullable, but isn’t
					// http://www.openradar.me/26404391
					if errorInfo != nil {
						// log and fall through to the fallback
						NSLog("opening %@ via applescript failed! %@", bundleIdentifier, errorInfo!)
						hadError = true
						break
					}
				}

				// if all went well, we’re done
				if !hadError {
					return true
				}
			}
		}

		// if we don’t know any applescript for the app or it failed for some reason, fall back to a
		// standard URL open
		NSLog("opening \(finalURLs) using \(bundleIdentifier)")
		if !NSWorkspace.shared.open(finalURLs, withAppBundleIdentifier: bundleIdentifier, options: .default, additionalEventParamDescriptor: nil, launchIdentifiers: nil) {
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
