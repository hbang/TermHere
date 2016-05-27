//
//  AppDelegate.swift
//  TermHere
//
//  Created by Adam Demasi on 13/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa

enum AppMode: UInt {
	case Unknown
	case Service, Settings
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	var appMode = AppMode.Unknown {
		didSet {
			let app = NSApplication.sharedApplication()

			// set the activation policy accordingly (mostly, whether the dock icon
			// shows or not)
			switch appMode {
			case .Unknown, .Service:
				app.setActivationPolicy(.Accessory)
				
			case .Settings:
				app.setActivationPolicy(.Regular)
			}
		}
	}

	// MARK: - App Delegate

	func applicationDidFinishLaunching(notification: NSNotification) {
		// register ourself
		let app = NSApplication.sharedApplication()
		app.servicesProvider = TerminalServiceProvider()
		app.registerServicesMenuSendTypes([
			NSStringPboardType,
			NSFilenamesPboardType,
			NSURLPboardType,
			NSMultipleTextSelectionPboardType
		], returnTypes: [])

		// force a refresh so we get added
		NSUpdateDynamicServices()
	}

	func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
		// we should only quit if we’ve been manually invoked
		return appMode == .Settings
	}

}
