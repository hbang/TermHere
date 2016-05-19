//
//  FinderSync.swift
//  TermHere Finder Extension
//
//  Created by Adam Demasi on 13/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa
import FinderSync
import TermHereCommon

class FinderSync: FIFinderSync {

	let finderController = FIFinderSyncController.defaultController()
	let preferences = Preferences.sharedInstance

	override init() {
		super.init()

		// set ourselves as “watching” everything by setting / as our root
		finderController.directoryURLs = [ NSURL(fileURLWithPath: "/") ]
	}

	// MARK: - Toolbar item

	override var toolbarItemName: String {
		return NSLocalizedString("NEW_TERMINAL_HERE", comment: "Button that opens a new terminal window.")
	}

	override var toolbarItemToolTip: String {
		return NSLocalizedString("NEW_TERMINAL_HERE_TOOLTIP", comment: "Explanation of what the New Terminal Here button does.")
	}

	override var toolbarItemImage: NSImage {
		return NSBundle.mainBundle().imageForResource("toolbar-terminal")!
	}

	override func menuForMenuKind(menuKind: FIMenuKind) -> NSMenu {
		// create the menu
		let menu = NSMenu(title: "")

		let newTabItem = menu.addItemWithTitle(NSLocalizedString("NEW_TERMINAL_HERE", comment: "Button that opens a new terminal tab."), action: #selector(newTerminal(_:)), keyEquivalent: "r")!
		newTabItem.target = self
		newTabItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.ShiftKeyMask.rawValue)

		let newWindowItem = menu.addItemWithTitle(NSLocalizedString("NEW_TERMINAL_WINDOW_HERE", comment: "Button that opens a new terminal window (shown when Option is held down)."), action: #selector(newTerminalWindow(_:)), keyEquivalent: "r")!
		newWindowItem.target = self
		newWindowItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.ShiftKeyMask.rawValue | NSEventModifierFlags.AlternateKeyMask.rawValue) // gee thanks apple
		newWindowItem.alternate = true

		if menuKind == .ToolbarItemMenu {
			menu.addItem(NSMenuItem.separatorItem())

			let settingsItem = menu.addItemWithTitle(NSLocalizedString("OPEN_SETTINGS", comment: "Button that opens the TermHere settings."), action: #selector(openSettings(_:)), keyEquivalent: "")!
			settingsItem.target = self
		}

		return menu
	}

	// MARK: - Callbacks

	func newTerminal(sender: NSMenuItem) {
		openTerminal(false)
	}

	func newTerminalWindow(sender: NSMenuItem) {
		openTerminal(true)
	}

	func openTerminal(newWindow: Bool) {
		// get the current directory and selected items, bail out if either is nil
		// (which shouldn’t be possible, but still)
		guard let target = finderController.targetedURL() else {
			NSLog("target is nil – attempting to open from an unknown path?")
			return
		}

		guard let items = finderController.selectedItemURLs() else {
			NSLog("items is nil – attempting to open from an unknown path?")
			return
		}

		var urls: [NSURL] = []

		// if items are selected, loop over them
		if items.count > 0 {
			for item in items {
				var isDirectory: AnyObject?

				do {
					// is it a directory?
					try item.getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey)

					if let result = isDirectory as? NSNumber {
						if result.boolValue {
							// add it to the array
							urls.append(item)
						}
					}
				} catch {
					NSLog("error while checking if %@ is a directory: %@", item, error as NSError)
				}
			}
		}

		// if we didn’t end up getting any urls, we can assume the user wants to
		// open a terminal in the current directory
		if urls.count == 0 {
			urls.append(target)
		}

		// determine the bundle id, falling back to terminal as default
		let bundleIdentifier = preferences.terminalBundleIdentifier
		let activationType = preferences.activationType

		var applescript: NSAppleScript?

		if bundleIdentifier == "com.apple.Terminal" {
			switch activationType {
			case .NewTab:
				applescript = NSAppleScript(source: "tell application \"Terminal\"\nactivate window 0\ndo script \"echo hi\" in window 0\nend tell")

			case .NewWindow:
				applescript = NSAppleScript(source: "tell application \"Terminal\"\nactivate window 0\ndo script \"echo hi\" in window 0\nend tell")

			case .SameTab:
				applescript = NSAppleScript(source: "tell application \"Terminal\"\nactivate window 0\ndo script \"echo hi\" in window 0\nend tell")
			}
		}

		if applescript != nil {
			var errorInfo: NSDictionary?
			applescript!.executeAndReturnError(&errorInfo)
		}

		// go ahead and open all of those urls in the specified terminal app
		NSWorkspace.sharedWorkspace().openURLs(urls, withAppBundleIdentifier: bundleIdentifier, options: .Default, additionalEventParamDescriptor: nil, launchIdentifiers: nil)
	}

	func openSettings(sender: NSMenuItem) {
		// launch the app
		NSWorkspace.sharedWorkspace().launchAppWithBundleIdentifier("au.com.hbang.TermHere", options: .Default, additionalEventParamDescriptor: nil, launchIdentifier: nil)
	}

}
