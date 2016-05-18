//
//  FinderSync.swift
//  TermHere Finder Extension
//
//  Created by Adam Demasi on 13/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {

	let finderController = FIFinderSyncController.defaultController()
	let preferences = NSUserDefaults(suiteName: "N2LN9ZT493.group.au.com.hbang.TermHere")!

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
		menu.addItemWithTitle(NSLocalizedString("NEW_TERMINAL_HERE", comment: "Button that opens a new terminal window."), action: #selector(openTerminal(_:)), keyEquivalent: "T")
		return menu
	}

	// MARK: - Callbacks

	@IBAction func openTerminal(sender: AnyObject?) {
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
		let bundleIdentifier = preferences.objectForKey("TerminalAppBundleIdentifier") as? String ?? "com.apple.Terminal"

		// go ahead and open all of those urls in the specified terminal app
		NSWorkspace.sharedWorkspace().openURLs(urls, withAppBundleIdentifier: bundleIdentifier, options: .Default, additionalEventParamDescriptor: nil, launchIdentifiers: nil)
	}

}
