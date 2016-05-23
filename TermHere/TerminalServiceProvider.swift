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

	static let applescriptCommands = NSDictionary(contentsOfURL: NSBundle.mainBundle().URLForResource("AppleScriptCommands", withExtension: "plist")!)!

	func launchTerminal(pasteboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
		// get the selected filenames
		guard let filenames = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String] else {
			// nothing? huh. ok
			error.memory = "No files provided"
			return
		}

		// map the filename strings to urls
		let urls = filenames.map { NSURL(fileURLWithPath: $0) }

		// launch them!
		if !launch(urls) {
			// if it failed, show an alert accordingly
			error.memory = NSLocalizedString("OPENING_APP_FAILED", comment: "Message displayed when the app fails to be opened.")

			let alert = NSAlert()
			alert.messageText = error.memory as! String
			alert.runModal()
		}
	}

	func launch(urls: [NSURL]) -> Bool {
		let preferences = Preferences.sharedInstance

		// determine the bundle id, falling back to terminal as default
		let bundleIdentifier = preferences.terminalBundleIdentifier
		let activationType = preferences.activationType

		// if the app is known, get its commands dictionary
		if let commands = TerminalServiceProvider.applescriptCommands[bundleIdentifier] as? [String: String] {
			// if the command is known, get its applescript
			if let command = commands[activationType.description] {
				// create an applescript object, wrapped in a function
				let applescript = NSAppleScript(source: "on runCommand(command)\n" + command + "\nend runCommand")

				var hadError = false

				// loop over urls to open
				for url in urls {
					// create our argument list
					let parameters = NSAppleEventDescriptor.listDescriptor()
					parameters.insertDescriptor(NSAppleEventDescriptor(string: url.path!), atIndex: 0)

					// use this legacy api monstrosity to create an apple event that calls
					// the function for us
					let event = NSAppleEventDescriptor(eventClass: AEEventClass(UInt(kASAppleScriptSuite)), eventID: AEEventID(UInt(kASSubroutineEvent)), targetDescriptor: NSAppleEventDescriptor.nullDescriptor(), returnID: AEReturnID(Int(kAutoGenerateReturnID)), transactionID: AETransactionID(UInt(kAnyTransactionID)))
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

		// if we don’t know any applescript for the app or it failed for some
		// reason, fall back to a standard URL open
		if !NSWorkspace.sharedWorkspace().openURLs(urls, withAppBundleIdentifier: bundleIdentifier, options: .Default, additionalEventParamDescriptor: nil, launchIdentifiers: nil) {
			return false
		}
		
		return true
	}
	
}
