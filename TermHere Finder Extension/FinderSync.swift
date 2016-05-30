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

	override init() {
		super.init()

		// set ourselves as “watching” everything by setting / as our root
		finderController.directoryURLs = [ NSURL(fileURLWithPath: "/") ]
	}

	// MARK: - Toolbar item

	override var toolbarItemName: String {
		return NSLocalizedString("NEW_TERMINAL_HERE", comment: "Button that opens a new terminal tab.")
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

		// if we're a disabled menu type, stop here
		let preferences = Preferences.sharedInstance

		switch menuKind {
		case .ContextualMenuForItems, .ContextualMenuForSidebar, .ContextualMenuForContainer:
			if !preferences.showInContextMenus {
				return menu
			}

		case .ToolbarItemMenu:
            if preferences.openOnToolbarButtonClick {
                self.newTerminal(nil)
                return menu
            }
			break
		}

		// create the new tab item
		let newTabItem = menu.addItemWithTitle(NSLocalizedString("NEW_TERMINAL_HERE", comment: "Button that opens a new terminal tab."), action: #selector(newTerminal(_:)), keyEquivalent: "X")!
		newTabItem.target = self

		// if this is the toolbar menu, add a separator and open settings item
		if menuKind == .ToolbarItemMenu {
			menu.addItem(NSMenuItem.separatorItem())

			let settingsItem = menu.addItemWithTitle(NSLocalizedString("OPEN_SETTINGS", comment: "Button that opens the TermHere settings."), action: #selector(openSettings(_:)), keyEquivalent: "")!
			settingsItem.target = self
		}

		return menu
	}

	// MARK: - Callbacks

	var urlsToOpen: [NSURL] {
		get {
			// get the current directory and selected items, bail out if either is nil
			// (which shouldn’t be possible, but still)
			guard let target = finderController.targetedURL() else {
				NSLog("target is nil – attempting to open from an unknown path?")
				return []
			}

			guard let items = finderController.selectedItemURLs() else {
				NSLog("items is nil – attempting to open from an unknown path?")
				return []
			}

			var urls: [NSURL] = []
            
            if Preferences.sharedInstance.openCurrentDirectory {
                urls.append(target)
                return urls;
            }

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

			return urls
		}
	}

	func newTerminal(sender: NSMenuItem?) {
		// get the filenames (map back to paths)
		let paths = urlsToOpen.map { $0.path! }

		// set up a pasteboard
		let pasteboard = NSPasteboard.pasteboardWithUniqueName()
		pasteboard.setPropertyList(paths as AnyObject, forType: NSFilenamesPboardType)

		// invoke the service
		NSPerformService("NEW_TERMINAL_HERE", pasteboard)
	}

	func openSettings(sender: NSMenuItem) {
		// launch the app
		NSWorkspace.sharedWorkspace().launchAppWithBundleIdentifier("au.com.hbang.TermHere", options: .Default, additionalEventParamDescriptor: nil, launchIdentifier: nil)
	}

}
