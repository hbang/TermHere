//
//  TerminalServiceProvider.swift
//  TermHere
//
//  Created by Adam Demasi on 21/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa

class TerminalServiceProvider: NSObject {
	
	let preferences = Preferences.sharedInstance

	@objc func launchTerminal(_ pasteboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
		executeService(pasteboard: pasteboard, error: error, withAppURL: preferences.terminalAppURL, fallbackAppURL: Preferences.fallbackTerminalAppURL)
	}
	
	@objc func launchEditor(_ pasteboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
		executeService(pasteboard: pasteboard, error: error, withAppURL: preferences.editorAppURL, fallbackAppURL: Preferences.fallbackEditorAppURL)
	}
	
	private func executeService(pasteboard: NSPasteboard, error errorOutput: AutoreleasingUnsafeMutablePointer<NSString?>, withAppURL appURL: URL, fallbackAppURL: URL) {
		// get the selected file names
		guard let items = pasteboard.propertyList(forType: .compatFilename) as? [String] else {
			// nothing? huh. ok
			errorOutput.pointee = "No files provided"
			return
		}
		
		// map the filename strings to urls
		let urls = items.map { URL(fileURLWithPath: $0) }
		
		// hop over to the main queue
		DispatchQueue.main.async {
			// launch them!
			do {
				try TerminalController.launch(urls: urls, withAppURL: appURL, fallbackAppURL: fallbackAppURL)
			} catch {
				// if it failed, show an alert accordingly
				errorOutput.pointee = error.localizedDescription as NSString
				
				let alert = NSAlert(error: error)
				alert.runModal()
			}
		}
	}

}
