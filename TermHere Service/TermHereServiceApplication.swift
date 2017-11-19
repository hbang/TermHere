//
//  TermHereServiceApplication.swift
//  TermHere
//
//  Created by Adam Demasi on 22/11/16.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa

// for some unknown reason, an AppDelegate just doesn’t work. init is never called. did finish
// launching is never called. i can’t be bothered to fathom why, so this is the next best thing
// TODO: is this a bug? in swift or cocoa?
@objc(TermHereServiceApplication) class TermHereServiceApplication: NSApplication {
	
	override func finishLaunching() {
		super.finishLaunching()
		
		// assign our service provider class
		servicesProvider = TerminalServiceProvider()
		
		// force a refresh so our service is known
		NSUpdateDynamicServices()
	}

}
