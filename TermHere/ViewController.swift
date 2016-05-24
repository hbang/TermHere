//
//  ViewController.swift
//  TermHere
//
//  Created by Adam Demasi on 13/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa
import CoreServices
import StoreKit
import TermHereCommon

class ViewController: NSViewController {

	@IBOutlet weak var pathControl: NSPathControl!

	@IBOutlet weak var finderToolbarCheckbox: NSButton!
	@IBOutlet weak var contextMenusCheckbox: NSButton!

	@IBOutlet weak var newTabRadioButton: NSButton!
	@IBOutlet weak var newWindowRadioButton: NSButton!
	@IBOutlet weak var lastTabRadioButton: NSButton!

	@IBOutlet weak var purchaseButton: NSButton!

	let purchaseController = PurchaseController()
	let preferences = Preferences.sharedInstance

	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		// get the app url or use the default
		pathControl.URL = preferences.terminalAppURL

		// listen for purchase info received notifications
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receivedPurchaseInfo(_:)), name: PurchaseControllerReceivedProductsNotification, object: nil)
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

	func receivedPurchaseInfo(notification: NSNotification) {
		let products = notification.object as! [SKProduct]
		let product = products[0]

		// format the price as a currency string
		let formatter = NSNumberFormatter()
		formatter.numberStyle = .CurrencyStyle
		formatter.locale = product.priceLocale

		let price = formatter.stringFromNumber(product.price!)!

		// enable the button and set the price label
		purchaseButton.enabled = true
		purchaseButton.title = NSString(format: NSLocalizedString("DONATE_WITH_PRICE", comment: "Button that allows a donation to be made. %@ is the donation amount."), price) as String
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

	@IBAction func finderToolbarChecked(sender: AnyObject) {
		preferences.showOnFinderToolbar = finderToolbarCheckbox.state == NSOnState
	}

	@IBAction func contextMenusChecked(sender: AnyObject) {
		preferences.showInContextMenus = contextMenusCheckbox.state == NSOnState
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

	@IBAction func purchaseClicked(sender: AnyObject) {
		purchaseController.purchase()
	}
	
}
