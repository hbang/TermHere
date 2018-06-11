//
//  Preferences.swift
//  TermHere
//
//  Created by Adam Demasi on 20/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Foundation

public enum EditorType: UInt {
	case app
	case command
}

public enum ActivationType: UInt, CustomStringConvertible {
	case newTab
	case newWindow
	case sameTab

	public var description: String {
		switch self {
		case .newTab:
			return "NewTab"
		case .newWindow:
			return "NewWindow"
		case .sameTab:
			return "SameTab"
		}
	}
}

open class Preferences {

	public static let sharedInstance = Preferences()
	
	public static let fallbackTerminalAppURL = URL(string: "file:///Applications/Utilities/Terminal.app")!
	public static let fallbackEditorAppURL = URL(string: "file:///Applications/TextEdit.app")!

	let preferences = UserDefaults(suiteName: "N2LN9ZT493.group.au.com.hbang.TermHere")!

	init() {
		preferences.register(defaults: [
			"HadFirstRun": false,

			"TerminalAppURL": Preferences.fallbackTerminalAppURL.path,
			"ShowInContextMenu": true,
			"OpenSelection": true,
			"TerminalActivationType": ActivationType.newTab.rawValue,
			
			"EditorAppURL": Preferences.fallbackEditorAppURL.path,
			"EditorShowInContextMenu": true,
			
			"*SandboxBookmarks": [:]
		])
	}

	open var hadFirstRun: Bool {
		get { return preferences.bool(forKey: "HadFirstRun") }
		set { preferences.set(newValue, forKey: "HadFirstRun") }
	}

	open var terminalAppURL: URL {
		get { return URL(fileURLWithPath: preferences.object(forKey: "TerminalAppURL") as! String) }
		set { preferences.set(newValue.path, forKey: "TerminalAppURL") }
	}
	
	open var terminalShowInContextMenu: Bool {
		get { return preferences.bool(forKey: "ShowInContextMenu") }
		set { preferences.set(newValue, forKey: "ShowInContextMenu") }
	}
	
	open var openSelection: Bool {
		get { return preferences.bool(forKey: "OpenSelection") }
		set { preferences.set(newValue, forKey: "OpenSelection") }
	}
	
	open var terminalActivationType: ActivationType {
		get { return ActivationType(rawValue: preferences.object(forKey: "TerminalActivationType") as? UInt ?? 0)! }
		set { preferences.set(newValue.rawValue, forKey: "TerminalActivationType") }
	}

	open var editorAppURL: URL {
		get { return URL(fileURLWithPath: preferences.object(forKey: "EditorAppURL") as! String) }
		set { preferences.set(newValue.path, forKey: "EditorAppURL") }
	}
	
	open var editorShowInContextMenu: Bool {
		get { return preferences.bool(forKey: "EditorShowInContextMenu") }
		set { preferences.set(newValue, forKey: "EditorShowInContextMenu") }
	}
	
	open var sandboxBookmarks: [String: Data] {
		get { return preferences.object(forKey: "*SandboxBookmarks") as! [String: Data] }
		set { preferences.set(newValue, forKey: "*SandboxBookmarks") }
	}
	
}
