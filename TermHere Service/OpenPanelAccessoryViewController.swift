//
//  OpenPanelAccessoryViewController.swift
//  TermHere
//
//  Created by Adam Demasi on 19/11/17.
//  Copyright © 2017 HASHBANG Productions. All rights reserved.
//

import Cocoa

class OpenPanelAccessoryViewController: NSViewController {
	
	@IBOutlet var label: NSTextField!
	
	init() {
		super.init(nibName: NSNib.Name(rawValue: "OpenPanelAccessoryViewController"), bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
