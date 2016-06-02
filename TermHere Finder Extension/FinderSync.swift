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

		let preferences = Preferences.sharedInstance

		switch menuKind {
		case .ContextualMenuForItems, .ContextualMenuForSidebar, .ContextualMenuForContainer:
			// if we're a disabled menu type, stop here
			if !preferences.showInContextMenus {
				return menu
			}

		case .ToolbarItemMenu:
			// if we're the toolbar item, cheat a little by treating this as our click
			// action
			self.newTerminal(nil)
			return menu
		}

		// create the new tab item
		let newTabItem = menu.addItemWithTitle(NSLocalizedString("NEW_TERMINAL_HERE", comment: "Button that opens a new terminal tab."), action: #selector(newTerminal(_:)), keyEquivalent: "X")!
		newTabItem.target = self

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

			let preferences = Preferences.sharedInstance

			// if selection is enabled and there are selected items, use them.
			// otherwise, use the current directory
			if preferences.openSelection && items.count > 0 {
				return items
			} else {
				return [ target ]
			}
		}
	}

	func newTerminal(sender: NSMenuItem?) {
		// gotta launch them all
		TerminalController.launch(urlsToOpen)
	}

}
