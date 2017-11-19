//
//  NSPasteboard+Additions.swift
//  TermHere Common
//
//  Created by Adam Demasi on 8/10/17.
//  Copyright © 2017 HASHBANG Productions. All rights reserved.
//

import Cocoa

extension NSPasteboard.PasteboardType {
	
	// s/o to apple for replacing the “right” way to reference pasteboard types with a way that’s only
	// supported on 10.13+
	// TODO: radar
	
	public static var compatString: NSPasteboard.PasteboardType {
		if #available(macOS 10.13, OSXApplicationExtension 10.13, *) {
			return .string
		} else {
			return NSPasteboard.PasteboardType(rawValue: "NSStringPboardType")
		}
	}
	
	public static var compatFileURL: NSPasteboard.PasteboardType {
		if #available(macOS 10.13, OSXApplicationExtension 10.13, *) {
			return .fileURL
		} else {
			return NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")
		}
	}
	
	public static var compatFilename: NSPasteboard.PasteboardType {
		return NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")
	}
	
	public static var compatURL: NSPasteboard.PasteboardType {
		if #available(macOS 10.13, OSXApplicationExtension 10.13, *) {
			return .URL
		} else {
			return NSPasteboard.PasteboardType(rawValue: "NSURLPboardType")
		}
	}
	
	public static var compatMultipleTextSelection: NSPasteboard.PasteboardType {
		if #available(macOS 10.13, OSXApplicationExtension 10.13, *) {
			return .multipleTextSelection
		} else {
			return NSPasteboard.PasteboardType(rawValue: "NSMultipleTextSelectionPboardType")
		}
	}
	
}
