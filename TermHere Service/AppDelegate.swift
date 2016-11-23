//
//  AppDelegate.swift
//  TermHere
//
//  Created by Adam Demasi on 22/11/16.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ notification: Notification) {
		let app = NSApplication.shared()

		// register ourself
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
