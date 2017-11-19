//
//  VolumeManager.swift
//  TermHere Finder Extension
//
//  Created by Adam Demasi on 7/10/17.
//  Copyright © 2017 HASHBANG Productions. All rights reserved.
//

import Foundation
import DiskArbitration

class VolumeManager {
	
	static let shared = VolumeManager()
	
	static let VolumesDidChangeNotification = Notification.Name(rawValue: "VolumeManagerVolumesDidChangeNotification")
	
	let session = DASessionCreate(kCFAllocatorDefault)!
	
	init() {
		// update the volumes now
		updateVolumes()
		
		// set ourselves up to get notifications when the list of volumes change
		DARegisterDiskAppearedCallback(session, nil, _volumeManagerDiskArbitrationCallback, nil)
		DARegisterDiskDisappearedCallback(session, nil, _volumeManagerDiskArbitrationCallback, nil)
		
		// schedule DiskArbitrator in the run loop so it actually sends the notifications
		DASessionScheduleWithRunLoop(session, RunLoop.main.getCFRunLoop(), RunLoopMode.defaultRunLoopMode as CFString)
	}
	
	func updateVolumes() {
		// get the new volumes, and post them in a notification
		let volumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [])
		NotificationCenter.default.post(name: VolumeManager.VolumesDidChangeNotification, object: volumes)
	}
	
	deinit {
		// remove callbacks and remove the session from the run loop
		DASessionUnscheduleFromRunLoop(session, RunLoop.main.getCFRunLoop(), RunLoopMode.defaultRunLoopMode as CFString)
	}
	
}

fileprivate func _volumeManagerDiskArbitrationCallback(disk: DADisk, context: UnsafeMutableRawPointer?) {
	// call through to updateVolumes() on the class
	VolumeManager.shared.updateVolumes()
}
