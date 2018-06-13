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

	override func viewDidLoad() {
		super.viewDidLoad()

		// fill in the labels
		let bundle = Bundle.main
		let info = bundle.infoDictionary!

		nameLabel.stringValue = "\(info["CFBundleName"]!) \(info["CFBundleShortVersionString"]!)"

		// construct the copyright/links label
		let copyright = info["NSHumanReadableCopyright"] as! String

		#if SANDBOX
		let hbangURL = URL(string: "https://hbang.com.au/termhere/")!
		let supportEmail = "support@hbang.ws"
		#else
		let hbangURL = URL(string: "https://hbang.ws/apps/termhere/")!
		let supportEmail = "support@hbang.ws"
		#endif
		
		var mailtoURL = URLComponents(string: "mailto:\(supportEmail)")!
		mailtoURL.queryItems = [
			URLQueryItem(name: "subject", value: "TermHere – Support")
		]
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		paragraphStyle.paragraphSpacing = 8

		let attributedString = NSMutableAttributedString(string: "\(copyright)\n\(hbangURL.host!) — \(supportEmail)", attributes: [
			.paragraphStyle: paragraphStyle,
			.font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
			.foregroundColor: NSColor.textColor
		])
		attributedString.addAttribute(.link, value: hbangURL, range: NSMakeRange(copyright.count + 1, hbangURL.host!.count))
		attributedString.addAttribute(.link, value: mailtoURL.url!, range: NSMakeRange(copyright.count + 1 + hbangURL.host!.count + 3, supportEmail.count))
		copyrightLabel.attributedStringValue = attributedString

		// construct the credits text view
		guard let data = try? Data(contentsOf: bundle.url(forResource: "Credits", withExtension: "html")!) else {
			NSLog("whoa, the credits failed to load?")
			return
		}
		
		let creditsAttributedString = NSMutableAttributedString(html: data, baseURL: bundle.resourceURL!, documentAttributes: nil)!
		creditsAttributedString.addAttribute(.foregroundColor, value: NSColor.textColor, range: NSMakeRange(0, creditsAttributedString.string.count))
		textView.textStorage!.append(creditsAttributedString)
	}

	@IBAction func closeClicked(_ sender: AnyObject) {
		view.window!.close()
	}

}
