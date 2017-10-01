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

	@IBOutlet weak var terminalPathControl: NSPathControl!

	@IBOutlet weak var editorAppRadioButton: NSButton!
	@IBOutlet weak var editorCommandRadioButton: NSButton!

	@IBOutlet weak var editorPathControl: NSPathControl!
	@IBOutlet weak var editorBrowseButton: NSButton!
	@IBOutlet weak var editorCommandTextField: NSTextField!

	@IBOutlet weak var openInTerminalCheckbox: NSButton!
	@IBOutlet weak var openInEditorCheckbox: NSButton!
	@IBOutlet weak var executeFileCheckbox: NSButton!

	@IBOutlet weak var contextMenusCheckbox: NSButtonCell!
	@IBOutlet weak var submenuCheckbox: NSButton!

	@IBOutlet weak var openSelectionCheckbox: NSButton!

	@IBOutlet weak var newTabRadioButton: NSButton!
	@IBOutlet weak var newWindowRadioButton: NSButton!
	@IBOutlet weak var lastTabRadioButton: NSButton!

	let preferences = Preferences.sharedInstance

	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		// set the values of the controls
		terminalPathControl.url = preferences.terminalAppURL
		editorPathControl.url = preferences.editorAppURL
		openInTerminalCheckbox.state = preferences.showInContextMenus ? .on : .off
		openSelectionCheckbox.state = preferences.openSelection ? .on : .off

		switch preferences.activationType {
		case .newTab:
			newTabRadioButton.state = .on

		case .newWindow:
			newWindowRadioButton.state = .on

		case .sameTab:
			lastTabRadioButton.state = .on
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

			alert.beginSheetModal(for: view.window!, completionHandler: { (_) in
				self.openExtensionPreferences()
			})
		}
	}

	func openExtensionPreferences() {
		// open the pref pane for extensions
		NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane"))
	}

	// MARK: - Callbacks

	typealias BrowseForAppCompletion = (_ path: URL, _ bundleIdentifier: String) -> Void

	func browseForApp(pathControl: NSPathControl, completion: @escaping BrowseForAppCompletion) {
		// set up the open panel
		let panel = NSOpenPanel()
		panel.title = NSLocalizedString("CHOOSE_APPLICATION", comment: "Title of the “Choose Application” window.")

		// only allow selecting app bundles
		panel.allowedFileTypes = [ kUTTypeApplicationBundle as String ]

		// configure the selected item. set the path to open to, then the filename to highlight
		panel.directoryURL = pathControl.url!.deletingLastPathComponent()
		panel.nameFieldStringValue = pathControl.url!.lastPathComponent
		panel.prompt = NSLocalizedString("CHOOSE", comment: "Button that chooses the selected app in the open panel.")

		// show the panel and define our callback
		panel.beginSheetModal(for: view.window!) { (result: NSApplication.ModalResponse) in
			// hopefully they clicked ok
			if result == .OK {
				// get the url that was selected and set it on the path control
				let url = panel.urls[0]
				pathControl.url = url

				// also get the bundle
				let bundle = Bundle(url: url)

				// call the callback
				completion(url, bundle!.bundleIdentifier!)
			}
		}
	}

	@IBAction func terminalBrowseClicked(_ sender: AnyObject) {
		browseForApp(pathControl: terminalPathControl) { (url: URL, bundleIdentifier: String) in
			self.preferences.terminalAppURL = url
			self.preferences.terminalBundleIdentifier = bundleIdentifier
		}
	}

	@IBAction func editorBrowseClicked(_ sender: AnyObject) {
		browseForApp(pathControl: editorPathControl) { (url: URL, bundleIdentifier: String) in
			self.preferences.editorAppURL = url
			self.preferences.editorBundleIdentifier = bundleIdentifier
		}
	}

	@IBAction func editorTypeChanged(_ sender: AnyObject) {
		if editorAppRadioButton.state == .on {
			preferences.editorType = .app
		} else if editorCommandRadioButton.state == .on {
			preferences.editorType = .command
		}

		switch preferences.editorType {
		case .app:
			editorPathControl.isEnabled = true
			editorBrowseButton.isEnabled = true
			editorCommandTextField.isEnabled = false
			editorBrowseButton.becomeFirstResponder()

		case .command:
			editorPathControl.isEnabled = false
			editorBrowseButton.isEnabled = false
			editorCommandTextField.isEnabled = true
			editorCommandTextField.becomeFirstResponder()
		}
	}

	@IBAction func editorCommandChanged(_ sender: AnyObject) {
		preferences.editorCommand = editorCommandTextField.stringValue
	}

	@IBAction func showOpenInTerminalChanged(_ sender: AnyObject) {
		preferences.showOpenInTerminal = openInTerminalCheckbox.state == .on
	}

	@IBAction func showOpenInEditorChanged(_ sender: AnyObject) {
		preferences.showOpenInEditor = openInEditorCheckbox.state == .on
	}

	@IBAction func showExecuteFileChanged(_ sender: AnyObject) {
		preferences.showExecuteFile = executeFileCheckbox.state == .on
	}

	@IBAction func contextMenusChanged(_ sender: AnyObject) {
		preferences.showInContextMenus = contextMenusCheckbox.state == .on
	}

	@IBAction func submenuChanged(_ sender: AnyObject) {
		preferences.showAsSubmenu = submenuCheckbox.state == .on
	}

	@IBAction func openSelectionChanged(_ sender: AnyObject) {
		preferences.openSelection = openSelectionCheckbox.state == .on
	}

	@IBAction func openInChanged(_ sender: AnyObject) {
		// set the preference according to the selected button
		if newTabRadioButton.state == .on {
			preferences.activationType = .newTab
		} else if newWindowRadioButton.state == .on {
			preferences.activationType = .newWindow
		} else if lastTabRadioButton.state == .on {
			preferences.activationType = .sameTab
		}
	}

	@IBAction func openPreferencesClicked(_ sender: AnyObject) {
		openExtensionPreferences()
	}
	
}
