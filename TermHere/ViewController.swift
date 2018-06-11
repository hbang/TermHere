//
//  ViewController.swift
//  TermHere
//
//  Created by Adam Demasi on 13/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa
import CoreServices

class ViewController: NSViewController {

	@IBOutlet weak var terminalPathControl: NSPathControl!
	@IBOutlet weak var terminalContextMenusCheckbox: NSButtonCell!
	@IBOutlet weak var openSelectionCheckbox: NSButton!
	
	@IBOutlet weak var terminalOpenInPopUpButton: NSPopUpButton!
	
	@IBOutlet weak var editorPathControl: NSPathControl!
	@IBOutlet weak var editorContextMenusCheckbox: NSButton!

	let preferences = Preferences.sharedInstance

	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		// set the values of the controls
		terminalPathControl.url = preferences.terminalAppURL
		editorPathControl.url = preferences.editorAppURL
		openSelectionCheckbox.state = preferences.openSelection ? .on : .off
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		requestExtensionEnable()
	}

	// MARK: - First Run

	func requestExtensionEnable() {
		// if this is the first run
		if preferences.hadFirstRun == false {
			// set hadFirstRun so this won’t activate again, then show the setup window
			preferences.hadFirstRun = true
			showSetupWindow()
		}
	}
	
	func showSetupWindow() {
		let newWindow = storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("setupWindowController")) as! NSWindowController
		newWindow.showWindow(self)
	}

	// MARK: - Callbacks

	typealias BrowseForAppCompletion = (_ path: URL) -> Void

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

				// call the callback
				completion(url)
			}
		}
	}

	@IBAction func terminalBrowseClicked(_ sender: AnyObject) {
		browseForApp(pathControl: terminalPathControl) { (url: URL) in
			self.preferences.terminalAppURL = url
		}
	}

	@IBAction func editorBrowseClicked(_ sender: AnyObject) {
		browseForApp(pathControl: editorPathControl) { (url: URL) in
			self.preferences.editorAppURL = url
		}
	}
	
	@IBAction func terminalContextMenusChanged(_ sender: AnyObject) {
		preferences.terminalShowInContextMenu = terminalContextMenusCheckbox.state == .on
	}
	
	@IBAction func editorContextMenusChanged(_ sender: AnyObject) {
		preferences.editorShowInContextMenu = editorContextMenusCheckbox.state == .on
	}

	@IBAction func openSelectionChanged(_ sender: AnyObject) {
		preferences.openSelection = openSelectionCheckbox.state == .on
	}

	@IBAction func openInChanged(_ sender: AnyObject) {
		// set the preference according to the selected item’s tag
		preferences.terminalActivationType = ActivationType(rawValue: UInt(terminalOpenInPopUpButton.selectedItem!.tag))!
	}
	
}
