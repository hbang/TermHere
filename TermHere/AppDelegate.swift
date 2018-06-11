//
//  AppDelegate.swift
//  TermHere
//
//  Created by Adam Demasi on 13/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa

#if !SANDBOX
import Sparkle
#endif

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

#if !SANDBOX
	let updater = SUUpdater.shared()!
#endif

	let serviceController = ServiceController()

	// MARK: - App delegate

	func applicationDidFinishLaunching(_ notification: Notification) {
		// in case of an upgrade, quit and relaunch the service app
		if Preferences.sharedInstance.hadFirstRun {
			do {
				try serviceController.relaunch()
			} catch {
				// naw. show an alert
				let alert = NSAlert(error: error)
				alert.runModal()
			}
		}

#if !SANDBOX
		// force a check for updates, since this app won’t be opened very often
		updater.checkForUpdatesInBackground()
#endif
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		// quit after the window is closed
		return true
	}

	// MARK: - Actions

	@IBAction func showHelp(_ sender: NSMenuItem) {
		NSWorkspace.shared.open(URL(string: "https://hbang.ws/support/")!)
	}
	
	@IBAction func checkForUpdates(_ sender: NSMenuItem) {
#if SANDBOX
		// open the app store page
		NSWorkspace.shared.open(URL(string: "macappstores://itunes.apple.com/app/id1114363220?mt=12")!)
#else
		// forward the command to sparkle
		updater.checkForUpdates(sender)
#endif
	}

}
