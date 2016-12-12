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

	// MARK: - App delegate

	func applicationDidFinishLaunching(_ notification: Notification) {
		// in case of an upgrade, quit and relaunch the service app
		do {
			try serviceController.relaunch()
		} catch {
			// naw. show an alert
			let alert = NSAlert(error: error)
			alert.runModal()
		}

		// force a check for updates
		updater.checkForUpdatesInBackground()
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		// quit after the window is closed
		return true
	}

	// MARK: - Actions

	@IBAction func showHelp(_ sender: NSMenuItem) {
		NSWorkspace.shared().open(URL(string: "https://hbang.ws/support/")!)
	}

}
