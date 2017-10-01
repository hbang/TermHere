//
//  ServiceController.swift
//  TermHere
//
//  Created by Adam Demasi on 22/11/16.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa

class ServiceController: NSObject {

	class var serviceURL: URL {
		return Bundle.main.sharedSupportURL!.appendingPathComponent("TermHere Service.service").absoluteURL
	}

	var runningApp: NSRunningApplication?

	func launch() throws {
		// launch a fresh instance
		do {
			try NSWorkspace.shared.launchApplication(at: ServiceController.serviceURL, options: .async, configuration: [:])
		} catch {
			NSLog("failed to launch the service: \(error.localizedDescription)")
			throw error
		}
	}

	func relaunch() throws {
		// terminate any previous instance of the service process (as it might be an outdated build),
		// wait for the termination if needed, and then launch a new instance of it

		// get the list of running apps
		let apps = NSWorkspace.shared.runningApplications

		// loop over to find our service app
		for (_, app) in apps.enumerated() {
			if app.bundleIdentifier == "ws.hbang.TermHere.TermHere-Service" {
				// keep a strong reference to this object around so it doesn’t get deallocated before our
				// KVO callback (would have been) fired
				runningApp = app
				break
			}
		}

		if runningApp == nil {
			// if no running app was found, then we can go ahead and launch it now
			do {
				try launch()
			} catch {
				throw error
			}
		} else {
			// register for KVO notifications
			runningApp!.addObserver(self, forKeyPath: "isTerminated", options: NSKeyValueObservingOptions(), context: nil)

			// kill it
			runningApp!.terminate()
		}
	}

	// MARK: - KVO

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard let app = object as? NSRunningApplication else {
			NSLog("huh? what is \(String(describing: object))?")
			return
		}

		// if the app is now terminated
		if app.isTerminated {
			// remove our observer
			app.removeObserver(self, forKeyPath: "isTerminated")

			// we don’t need this any more
			runningApp = nil

			// launch a new instance
			do {
				try launch()
			} catch {
				// ¯\_(ツ)_/¯
			}
		}
	}

}
