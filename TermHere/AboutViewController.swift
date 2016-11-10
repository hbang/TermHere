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

		nameLabel.stringValue = "\(info["CFBundleName"]!) \(info["CFBundleShortVersionString"]!) (\(info["CFBundleVersion"]!))"
		copyrightLabel.stringValue = info["NSHumanReadableCopyright"] as! String

		guard let data = try? Data(contentsOf: bundle.url(forResource: "Credits", withExtension: "html")!) else {
			NSLog("whoa, the credits failed to load?")
			return
		}

		textView.textStorage!.append(NSAttributedString(html: data, baseURL: bundle.resourceURL!, documentAttributes: nil)!)
	}

	@IBAction func closeClicked(_ sender: AnyObject) {
		view.window!.close()
	}

}
