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

	@IBOutlet weak var contextMenusCheckbox: NSButton!
	@IBOutlet weak var openSelectionCheckbox: NSButton!

	@IBOutlet weak var newTabRadioButton: NSButton!
	@IBOutlet weak var newWindowRadioButton: NSButton!
	@IBOutlet weak var lastTabRadioButton: NSButton!
	
	let preferences = Preferences.sharedInstance

	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		// set the values of the controls
		pathControl.url = preferences.terminalAppURL
		contextMenusCheckbox.state = preferences.showInContextMenus ? 1 : 0
		openSelectionCheckbox.state = preferences.openSelection ? 1 : 0

		switch preferences.activationType {
		case .newTab:
			newTabRadioButton.state = NSOnState

		case .newWindow:
			newWindowRadioButton.state = NSOnState

		case .sameTab:
			lastTabRadioButton.state = NSOnState
		}
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		requestExtensionEnable()
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
			alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK button label."))

			alert.beginSheetModal(for: view.window!, completionHandler: { (result: NSModalResponse) in
				self.openExtensionPreferences()
			}) 
		}
	}

	// MARK: - Callbacks

	func openExtensionPreferences() {
		// open the pref pane for extensions
		NSWorkspace.shared().open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane"))
	}

	@IBAction func browseClicked(_ sender: AnyObject) {
		// set up the open panel
		let panel = NSOpenPanel()
		panel.title = NSLocalizedString("CHOOSE_APPLICATION", comment: "Title of the “Choose Application” window.")

		// only allow selecting app bundles
		panel.allowedFileTypes = [ kUTTypeApplicationBundle as String ]

		// configure the selected item. set the path to open to, then the filename
		// to highlight
		panel.directoryURL = pathControl.url!.deletingLastPathComponent()
		panel.nameFieldStringValue = pathControl.url!.lastPathComponent
		panel.prompt = NSLocalizedString("CHOOSE", comment: "Button that chooses the selected app in the open panel.")

		// show the panel and define our callback
		panel.beginSheetModal(for: view.window!) { (result: NSModalResponse) in
			// hopefully they clicked ok
			if result == NSModalResponseOK {
				// set the url on the path control and commit to preferences
				let url = panel.urls[0]
				self.pathControl.url = url
				self.preferences.terminalAppURL = url

				// also get the bundle identifier
				let bundle = Bundle(url: url)
				self.preferences.terminalBundleIdentifier = bundle!.bundleIdentifier!
			}
		}
	}

	@IBAction func contextMenusChecked(_ sender: AnyObject) {
		preferences.showInContextMenus = contextMenusCheckbox.state == NSOnState
	}
	
	@IBAction func openSelectionChanged(_ sender: AnyObject) {
		preferences.openSelection = openSelectionCheckbox.state == NSOnState
	}

	@IBAction func openInChanged(_ sender: AnyObject) {
		// set the preference according to the selected button
		if newTabRadioButton.state == NSOnState {
			preferences.activationType = .newTab
		} else if newWindowRadioButton.state == NSOnState {
			preferences.activationType = .newWindow
		} else if lastTabRadioButton.state == NSOnState {
			preferences.activationType = .sameTab
		}
	}

	@IBAction func openPreferencesClicked(_ sender: AnyObject) {
		openExtensionPreferences()
	}
	
}
