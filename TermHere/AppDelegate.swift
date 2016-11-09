//
//  AppDelegate.swift
//  TermHere
//
//  Created by Adam Demasi on 13/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa
import Sparkle

enum AppMode: UInt {
	case unknown
	case service, settings
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var updater: SUUpdater!

	var appMode = AppMode.unknown {
		didSet {
			let app = NSApplication.shared()

			// set the activation policy accordingly (mostly, whether the dock icon
			// shows or not)
			switch appMode {
			case .unknown, .service:
				app.setActivationPolicy(.accessory)
				
			case .settings:
				app.setActivationPolicy(.regular)
			}
		}
	}

	// MARK: - App Delegate

	func applicationDidFinishLaunching(_ notification: Notification) {
		// hide the window
		let app = NSApplication.shared()
		app.hide(nil)

		// wait a bit
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			// if we’re not in service mode
			if self.appMode != .service {
				// show the window
				app.activate(ignoringOtherApps: true)

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

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		// we should only quit if we’ve been manually invoked
		return appMode == .settings
	}

}
