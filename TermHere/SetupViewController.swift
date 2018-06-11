//
//  SetupViewController.swift
//  TermHere
//
//  Created by Adam Demasi on 11/6/18.
//  Copyright © 2018 HASHBANG Productions. All rights reserved.
//

import Cocoa

class SetupViewController: NSViewController {

	@IBOutlet weak var extensionImageView: NSImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		extensionImageView.image = NSWorkspace.shared.icon(forFile: "/System/Library/PreferencePanes/Extensions.prefPane")
	}
	
	@IBAction func openExtensionPreferences(_ sender: AnyObject) {
		// open the pref pane for extensions
		NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane"))
	}
	
	@IBAction func launchService(_ sender: NSButton) {
		let appDelegate = NSApplication.shared.delegate as! AppDelegate
		
		do {
			try appDelegate.serviceController.relaunch()
			sender.isEnabled = false
		} catch {
			// naw. show an alert
			let alert = NSAlert(error: error)
			alert.runModal()
		}
	}
	
	@IBAction func closeClicked(_ sender: AnyObject) {
		view.window!.close()
	}

}
