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
		NotificationCenter.default.addObserver(self, selector: #selector(receivedPurchaseInfo(_:)), name: NSNotification.Name(rawValue: PurchaseControllerReceivedProductsNotification), object: nil)

		// fill in the labels
		let bundle = Bundle.main
		let info = bundle.infoDictionary!

		nameLabel.stringValue = "\(info["CFBundleName"]!) \(info["CFBundleShortVersionString"]!) (\(info["CFBundleVersion"]!))"
		copyrightLabel.stringValue = info["NSHumanReadableCopyright"] as! String

		guard let data = try? Data(contentsOf: bundle.url(forResource: "Credits", withExtension: "rtf")!) else {
			NSLog("whoa, the credits failed to load?")
			return
		}

		textView.textStorage!.append(NSAttributedString(rtf: data, documentAttributes: nil)!)
	}

	func receivedPurchaseInfo(_ notification: Notification) {
		let products = notification.object as! [SKProduct]
		let product = products[0]

		// format the price as a currency string
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = product.priceLocale

		let price = formatter.string(from: product.price)!

		// enable the button and set the price label
		purchaseButton.isEnabled = true
		purchaseButton.title = NSString(format: NSLocalizedString("DONATE_WITH_PRICE", comment: "Button that allows a donation to be made. %@ is the donation amount.") as NSString, price) as String
	}

	@IBAction func purchaseClicked(_ sender: AnyObject) {
		purchaseController.purchase()
	}

	@IBAction func closeClicked(_ sender: AnyObject) {
		view.window!.close()
	}

}
