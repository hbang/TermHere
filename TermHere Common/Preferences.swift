//
//  Preferences.swift
//  TermHere
//
//  Created by Adam Demasi on 20/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Foundation

public enum ActivationType: UInt, CustomStringConvertible {
	case NewTab
	case NewWindow
	case SameTab

	public var description: String {
		switch self {
		case .NewTab:
			return "NewTab"
		case .NewWindow:
			return "NewWindow"
		case .SameTab:
			return "SameTab"
		}
	}
}

public class Preferences {

	public static let sharedInstance = Preferences()

	let preferences = NSUserDefaults(suiteName: "N2LN9ZT493.group.au.com.hbang.TermHere")!

	init() {
		preferences.registerDefaults([
			"HadFirstRun": false,

			"TerminalAppURL": "file:///Applications/Utilities/Terminal.app",
			"TerminalAppBundleIdentifier": "com.apple.Terminal",

			"OpenCurrentDirectory": false,
			"ShowInContextMenu": true,
			"TerminalActivationType": ActivationType.NewTab.rawValue
		])
	}

	public var hadFirstRun: Bool {
		get { return preferences.boolForKey("HadFirstRun") }
		set { preferences.setBool(newValue, forKey: "HadFirstRun") }
	}

	public var terminalAppURL: NSURL {
		get { return NSURL(string: preferences.objectForKey("TerminalAppURL") as! String)! }
		set { preferences.setURL(newValue, forKey: "TerminalAppURL") }
	}

	public var terminalBundleIdentifier: String {
		get { return preferences.stringForKey("TerminalAppBundleIdentifier")! }
		set { preferences.setObject(newValue, forKey: "TerminalAppBundleIdentifier") }
	}

	public var showInContextMenus: Bool {
		get { return preferences.boolForKey("ShowInContextMenu") }
		set { preferences.setBool(newValue, forKey: "ShowInContextMenu") }
	}
	
	public var openCurrentDirectory: Bool {
		get { return preferences.boolForKey("OpenCurrentDirectory") }
		set { preferences.setBool(newValue, forKey: "OpenCurrentDirectory") }
	}

	public var activationType: ActivationType {
		get { return ActivationType(rawValue: preferences.objectForKey("TerminalActivationType") as? UInt ?? 0)! }
		set { preferences.setObject(newValue.rawValue, forKey: "TerminalActivationType") }
	}
	
}
