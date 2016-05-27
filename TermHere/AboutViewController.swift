//
//  AboutViewController.swift
//  TermHere
//
//  Created by Adam Demasi on 24/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa
import StoreKit

class AboutViewController: NSViewController {

	@IBOutlet weak var nameLabel: NSTextField!
	@IBOutlet weak var copyrightLabel: NSTextField!
	@IBOutlet var textView: NSTextView!
	@IBOutlet weak var purchaseButton: NSButton!

	let purchaseController = PurchaseController()

	override func viewDidLoad() {
		super.viewDidLoad()

		// listen for purchase info received notifications
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receivedPurchaseInfo(_:)), name: PurchaseControllerReceivedProductsNotification, object: nil)

		// fill in the labels
		let bundle = NSBundle.mainBundle()
		let info = bundle.infoDictionary!

		nameLabel.stringValue = "\(info["CFBundleName"]!) \(info["CFBundleShortVersionString"]!) (\(info["CFBundleVersion"]!))"
		copyrightLabel.stringValue = info["NSHumanReadableCopyright"] as! String

		guard let data = NSData(contentsOfURL: bundle.URLForResource("Credits", withExtension: "rtf")!) else {
			NSLog("whoa, the credits failed to load?")
			return
		}

		textView.textStorage!.appendAttributedString(NSAttributedString(RTF: data, documentAttributes: nil)!)
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

	@IBAction func purchaseClicked(sender: AnyObject) {
		purchaseController.purchase()
	}

	@IBAction func closeClicked(sender: AnyObject) {
		view.window!.close()
	}

}
