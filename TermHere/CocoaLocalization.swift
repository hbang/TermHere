//
//  CocoaLocalization.swift
//  TermHere
//
//  Created by Adam Demasi on 25/9/16.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Foundation
import AppKit

func localize(_ key: String, table: String = "Localizable") -> String {
	return NSLocalizedString(key, tableName: table, bundle: Bundle.main, value: "", comment: "")
}

extension NSTextField {

	@IBInspectable var localizationTable: String {
		get { return "" }
		set {
			cell!.title = localize(cell!.title, table: newValue)
		}
	}

}

extension NSButton {

	@IBInspectable var localizationTable: String {
		get { return "" }
		set {
			cell!.title = localize(cell!.title, table: newValue)
		}
	}

}

extension NSBox {
	
	@IBInspectable var localizationTable: String {
		get { return "" }
		set {
			title = localize(title, table: newValue)
		}
	}
	
}

extension NSMenuItem {
	
	@IBInspectable var localizationTable: String {
		get { return "" }
		set {
			title = localize(title, table: newValue)
		}
	}
	
}
