//
//  Preferences.swift
//  TermHere
//
//  Created by Adam Demasi on 20/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Foundation

public enum ActivationType: UInt {
	case NewTab
	case NewWindow
	case SameTab
}

public class Preferences {

	public static let sharedInstance = Preferences()

	let preferences = NSUserDefaults(suiteName: "N2LN9ZT493.group.au.com.hbang.TermHere")!

	init() {
		preferences.registerDefaults([
			"HadFirstRun": false,

			"TerminalAppURL": "file:///Applications/Utilities/Terminal.app",
			"TerminalAppBundleIdentifier": "com.apple.Terminal",

			"ShowInToolbar": true,
			"ShowInContextMenu": true,
			"TerminalActivationType": ActivationType.NewTab.rawValue
		])
	}

	public var hadFirstRun: Bool {
		get { return preferences.boolForKey("HadFirstRun") }
		set { preferences.setBool(newValue, forKey: "HadFirstRun") }
	}

	public var terminalAppURL: NSURL {
		get { return preferences.URLForKey("TerminalAppURL")! }
		set { preferences.setURL(newValue, forKey: "TerminalAppURL") }
	}

	public var terminalBundleIdentifier: String {
		get { return preferences.stringForKey("TerminalAppBundleIdentifier")! }
		set { preferences.setObject(newValue, forKey: "TerminalAppBundleIdentifier") }
	}

	public var showOnFinderToolbar: Bool {
		get { return preferences.boolForKey("ShowInToolbar") }
		set { preferences.setBool(newValue, forKey: "ShowInToolbar") }
	}

	public var showInContextMenus: Bool {
		get { return preferences.boolForKey("ShowInContextMenu") }
		set { preferences.setBool(newValue, forKey: "ShowInContextMenu") }
	}

	public var activationType: ActivationType {
		get { return ActivationType(rawValue: preferences.objectForKey("TerminalActivationType") as? UInt ?? 0)! }
		set { preferences.setObject(newValue.rawValue, forKey: "TerminalActivationType") }
	}
	
}
