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
		// hide the window
		let app = NSApplication.sharedApplication()
		app.hide(nil)

		// wait a bit
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
			// if we’re not in service mode
			if self.appMode != .Service {
				// show the window
				app.activateIgnoringOtherApps(true)

				// register ourself
				app.servicesProvider = TerminalServiceProvider()
				app.registerServicesMenuSendTypes([
					NSStringPboardType,
					NSFilenamesPboardType,
					NSURLPboardType,
					NSMultipleTextSelectionPboardType
				], returnTypes: [])
				
				// force a refresh so our service is known
				NSUpdateDynamicServices()
			}
		}
	}

	func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
		// we should only quit if we’ve been manually invoked
		return appMode == .Settings
	}

}
