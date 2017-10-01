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

	open static let sharedInstance = Preferences()

	let preferences = UserDefaults(suiteName: "N2LN9ZT493.group.ws.hbang.TermHere")!

	init() {
		preferences.register(defaults: [
			"HadFirstRun": false,

			"TerminalAppURL": "file:///Applications/Utilities/Terminal.app",
			"TerminalAppBundleIdentifier": "com.apple.Terminal",

			"EditorType": EditorType.app.rawValue,
			"EditorAppURL": "file:///Applications/TextEdit.app",
			"EditorAppBundleIdentifier": "com.apple.TextEdit",
			"EditorCommand": "nano",

			"ShowOpenInTerminal": true,
			"ShowOpenInEditor": true,
			
			"ShowInContextMenu": true,
			"ShowAsSubmenu": false,

			"OpenSelection": true,

			"TerminalActivationType": ActivationType.newTab.rawValue
		])
	}

	open var hadFirstRun: Bool {
		get { return preferences.bool(forKey: "HadFirstRun") }
		set { preferences.set(newValue, forKey: "HadFirstRun") }
	}

	open var terminalAppURL: URL {
		get { return URL(fileURLWithPath: preferences.object(forKey: "TerminalAppURL") as! String) }
		set { preferences.set(newValue, forKey: "TerminalAppURL") }
	}

	open var terminalBundleIdentifier: String {
		get { return preferences.string(forKey: "TerminalAppBundleIdentifier")! }
		set { preferences.set(newValue, forKey: "TerminalAppBundleIdentifier") }
	}

	open var editorType: EditorType {
		get { return EditorType(rawValue: preferences.object(forKey: "EditorType") as? UInt ?? 0)! }
		set { preferences.set(newValue.rawValue, forKey: "EditorType") }
	}

	open var editorAppURL: URL {
		get { return URL(fileURLWithPath: preferences.object(forKey: "EditorAppURL") as! String) }
		set { preferences.set(newValue, forKey: "EditorAppURL") }
	}

	open var editorBundleIdentifier: String {
		get { return preferences.string(forKey: "EditorAppBundleIdentifier")! }
		set { preferences.set(newValue, forKey: "EditorAppBundleIdentifier") }
	}

	open var editorCommand: String {
		get { return preferences.string(forKey: "EditorCommand")! }
		set { preferences.set(newValue, forKey: "EditorCommand") }
	}

	open var showOpenInTerminal: Bool {
		get { return preferences.bool(forKey: "ShowOpenInTerminal") }
		set { preferences.set(newValue, forKey: "ShowOpenInTerminal") }
	}

	open var showOpenInEditor: Bool {
		get { return preferences.bool(forKey: "ShowOpenInEditor") }
		set { preferences.set(newValue, forKey: "ShowOpenInEditor") }
	}

	open var showExecuteFile: Bool {
		get { return preferences.bool(forKey: "ShowExecuteFile") }
		set { preferences.set(newValue, forKey: "ShowExecuteFile") }
	}

	open var openSelection: Bool {
		get { return preferences.bool(forKey: "OpenSelection") }
		set { preferences.set(newValue, forKey: "OpenSelection") }
	}

	open var showInContextMenus: Bool {
		get { return preferences.bool(forKey: "ShowInContextMenu") }
		set { preferences.set(newValue, forKey: "ShowInContextMenu") }
	}

	open var showAsSubmenu: Bool {
		get { return preferences.bool(forKey: "ShowAsSubmenu") }
		set { preferences.set(newValue, forKey: "ShowAsSubmenu") }
	}

	open var activationType: ActivationType {
		get { return ActivationType(rawValue: preferences.object(forKey: "TerminalActivationType") as? UInt ?? 0)! }
		set { preferences.set(newValue.rawValue, forKey: "TerminalActivationType") }
	}
	
}
