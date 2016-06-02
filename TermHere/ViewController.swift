//
//  ViewController.swift
//  TermHere
//
//  Created by Adam Demasi on 13/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa
import CoreServices
import TermHereCommon

class ViewController: NSViewController {

	@IBOutlet weak var pathControl: NSPathControl!

	@IBOutlet weak var finderToolbarCheckbox: NSButton!
	@IBOutlet weak var contextMenusCheckbox: NSButton!
	@IBOutlet weak var openCurrentDirectoryCheckbox: NSButton!

	@IBOutlet weak var newTabRadioButton: NSButton!
	@IBOutlet weak var newWindowRadioButton: NSButton!
	@IBOutlet weak var lastTabRadioButton: NSButton!
	
	let preferences = Preferences.sharedInstance

	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		// get the app url or use the default
		pathControl.URL = preferences.terminalAppURL
		contextMenusCheckbox.state = preferences.showInContextMenus ? 1 : 0
		openCurrentDirectoryCheckbox.state = preferences.openCurrentDirectory ? 1 : 0
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		requestExtensionEnable()

		// set the app to settings mode if needed
		let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate

		if appDelegate.appMode != .Service {
			appDelegate.appMode = .Settings
		}
	}

	// MARK: - First Run

	func requestExtensionEnable() {
		// if this is the first run
		if preferences.hadFirstRun == false {
			// set hadFirstRun so this won’t activate again
			preferences.hadFirstRun = true

			// construct and show an alert asking to enable the extension
			let alert = NSAlert()
			alert.messageText = NSLocalizedString("PLEASE_ENABLE", comment: "Title of prompt asking the user to enable the extension.")
			alert.informativeText = NSLocalizedString("PLEASE_ENABLE_EXPLANATION", comment: "Explanation of how to enable the extension.")
			alert.addButtonWithTitle(NSLocalizedString("OK", comment: "OK button label"))

			alert.beginSheetModalForWindow(view.window!) { (result: NSModalResponse) in
				self.openExtensionPreferences()
			}
		}
	}

	// MARK: - Callbacks

	func openExtensionPreferences() {
		// open the pref pane for extensions
		NSWorkspace.sharedWorkspace().openURL(NSURL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane"))
	}

	@IBAction func browseClicked(sender: AnyObject) {
		// set up the open panel
		let panel = NSOpenPanel()
		panel.title = NSLocalizedString("CHOOSE_APPLICATION", comment: "Title of the “Choose Application” window.")

		// only allow selecting app bundles
		panel.allowedFileTypes = [ kUTTypeApplicationBundle as String ]

		// configure the selected item. set the path to open to, then the filename
		// to highlight
		panel.directoryURL = pathControl.URL!.URLByDeletingLastPathComponent
		panel.nameFieldStringValue = pathControl.URL!.lastPathComponent!
		panel.prompt = NSLocalizedString("CHOOSE", comment: "Button that chooses the selected app in the open panel.")

		// show the panel and define our callback
		panel.beginSheetModalForWindow(view.window!) { (result: NSModalResponse) in
			// hopefully they clicked ok
			if result == NSModalResponseOK {
				// set the url on the path control and commit to preferences
				let url = panel.URLs[0]
				self.pathControl.URL = url
				self.preferences.terminalAppURL = url

				// also get the bundle identifier
				let bundle = NSBundle(URL: url)
				self.preferences.terminalBundleIdentifier = bundle!.bundleIdentifier!
			}
		}
	}

	@IBAction func contextMenusChecked(sender: AnyObject) {
		preferences.showInContextMenus = contextMenusCheckbox.state == NSOnState
	}
	
	@IBAction func openCurrentDirectoryChecked(sender: AnyObject) {
		preferences.openCurrentDirectory = openCurrentDirectoryCheckbox.state == NSOnState
	}

	@IBAction func openInChanged(sender: AnyObject) {
		// set the preference according to the selected button
		if newTabRadioButton.state == NSOnState {
			preferences.activationType = .NewTab
		} else if newWindowRadioButton.state == NSOnState {
			preferences.activationType = .NewWindow
		} else if lastTabRadioButton.state == NSOnState {
			preferences.activationType = .SameTab
		}
	}

	@IBAction func openPreferencesClicked(sender: AnyObject) {
		openExtensionPreferences()
	}
	
}
