//
//  AppDelegate.swift
//  TermHere
//
//  Created by Adam Demasi on 13/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var updater: SUUpdater!

	let serviceController = ServiceController()

	func applicationDidFinishLaunching(_ notification: Notification) {
		// in case of an upgrade, quit and relaunch the service app
		serviceController.relaunch()

		// force a check for updates
		updater.checkForUpdatesInBackground()
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		// quit after the window is closed
		return true
	}

}
