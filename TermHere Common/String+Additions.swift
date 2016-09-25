//
//  String+Additions.swift
//  TermHere
//
//  Created by Adam Demasi on 25/9/16.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Foundation

extension String {

	static let shellEscapeCharacterSet = NSCharacterSet(charactersIn: " ()[]<>\\|'\"`;!?#$&*")

	mutating func escapeCharacters(in set: NSCharacterSet) {
		// initialise a new string
		var newString = ""

		// loop over each UTF16 byte
		for (_, byte) in utf16.enumerated() {
			// turn it back into a String so we can use it in a sec
			let character = String(utf16CodeUnits: [ byte ], count: 1)

			// if this character exists in the set
			if set.characterIsMember(byte) {
				// append it, escaping it
				newString += "\\" + character
			} else {
				// else just append it on its own
				newString += character
			}
		}

		// replace ourself with the new string
		self = newString
	}

	mutating func escapeShellArgument() {
		escapeCharacters(in: String.shellEscapeCharacterSet)
	}

}
