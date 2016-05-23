//
//  AppDelegate.swift
//  TermHere
//
//  Created by Adam Demasi on 13/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

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
		NSUpdateDynamicServices();
	}

	func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
		return true
	}

}
