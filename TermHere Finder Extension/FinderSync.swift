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

	let finderController = FIFinderSyncController.default()
	let preferences = Preferences.sharedInstance

	override init() {
		super.init()

		// as a safe initial fallback, start off using / as our only root directory
		finderController.directoryURLs = [ URL(fileURLWithPath: "/") ]
		
		// ensure VolumeManager’s shared instance has been instantiated
		_ = VolumeManager.shared
		
		// set up our notification observer
		NotificationCenter.default.addObserver(forName: VolumeManager.VolumesDidChangeNotification, object: nil, queue: OperationQueue.current!) { (notification) in
			// set ourselves as “watching” everything by setting each volume as our root
			self.finderController.directoryURLs = Set(notification.object as! [URL])
		}
	}
	
}

extension FinderSync {

	override var toolbarItemName: String {
		return "TermHere"
	}

	override var toolbarItemToolTip: String {
		return NSLocalizedString("NEW_TERMINAL_HERE_TOOLTIP", comment: "Explanation of what the Open in Terminal button does.")
	}

	override var toolbarItemImage: NSImage {
		return #imageLiteral(resourceName: "toolbar-terminal")
	}

	override func menu(for menuKind: FIMenuKind) -> NSMenu {
		// create the menu
		let menu = NSMenu(title: "")

		// create the new tab item
		if preferences.terminalShowInContextMenu {
			let appURL = preferences.terminalAppURL
			let title = String(format: NSLocalizedString("OPEN_IN_APP", comment: "Button that opens a new terminal tab."), nameForApp(url: appURL))
			
			let newTabItem = menu.addItem(withTitle: title, action: #selector(newTerminal(_:)), keyEquivalent: "X")
			newTabItem.target = self
			newTabItem.image = NSWorkspace.shared.icon(forFile: appURL.path)
		}
		
		// create the editor item
		if preferences.editorShowInContextMenu {
			let appURL = preferences.editorAppURL
			let title = String(format: NSLocalizedString("EDIT_IN_APP", comment: "Button that opens the file in a text editor."), nameForApp(url: appURL))
			
			let openInEditorItem = menu.addItem(withTitle: title, action: #selector(openEditor(_:)), keyEquivalent: "E")
			openInEditorItem.target = self
			openInEditorItem.image = NSWorkspace.shared.icon(forFile: appURL.path)
		}

		return menu
	}
	
}

extension FinderSync {

	private var urlsToOpen: [URL] {
		get {
			// get the current directory and selected items, bail out if either is nil (which shouldn’t be
			// possible, but still)
			guard let target = finderController.targetedURL() else {
				NSLog("target is nil – attempting to open from an unknown path?")
				return []
			}

			guard let items = finderController.selectedItemURLs() else {
				NSLog("items is nil – attempting to open from an unknown path?")
				return []
			}

			// if opening selection is enabled and there are selected items, use them. otherwise, use the
			// current directory
			if preferences.openSelection && items.count > 0 {
				return items
			} else {
				return [ target ]
			}
		}
	}
	
	private func nameForApp(url: URL) -> String {
		var name: String?
		
		do {
			// get the localized name – the filename may be different from what the user usually sees
			let result = try url.resourceValues(forKeys: [ .localizedNameKey ])
			name = result.localizedName
		} catch {
			NSLog("failed to get name of app, may not exist? \(error)")
		}
		
		// if we didn’t get a name, fall back to the filename
		if name == nil {
			name = url.lastPathComponent
		}
		
		// remove the .app suffix if it exists, using this wonderful mess of swift over-designed api
		if name!.hasSuffix(".app") {
			let endIndex = name!.index(name!.endIndex, offsetBy: -4)
			name = String(name![name!.startIndex..<endIndex])
		}
		
		return name ?? url.deletingPathExtension().lastPathComponent
	}
	
	func runSelectedFiles(withAppURL appURL: URL, fallbackAppURL: URL, fallbackService: String) {
		let urls = urlsToOpen
		
		// hop over to the main queue
		DispatchQueue.main.async {
			// launch them!
			let service = ServiceRunner.serviceName(forAppURL: appURL, fallbackAppURL: fallbackAppURL, fallbackService: fallbackService)
			_ = ServiceRunner.run(service: service, withFileURLs: urls)
		}
	}
	
	@objc func newTerminal(_ sender: NSMenuItem?) {
		runSelectedFiles(withAppURL: preferences.terminalAppURL, fallbackAppURL: Preferences.fallbackTerminalAppURL, fallbackService: "New Terminal Here")
	}
	
	@objc func openEditor(_ sender: NSMenuItem?) {
		runSelectedFiles(withAppURL: preferences.editorAppURL, fallbackAppURL: Preferences.fallbackEditorAppURL, fallbackService: "Open in Editor")
	}

}
