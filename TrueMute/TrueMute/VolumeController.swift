//
//  VolumeController.swift
//  TrueMute
//
//  Created by Sky Liu on 4/9/24.
//

import AppKit
import ISSoundAdditions

class VolumeController: NSObject, NSApplicationDelegate {
    static var shared = VolumeController()
    private var volumeCheckTimer: Timer?
    private static var _isMuted: Bool = false
    private var unmuteVolume: Float = -1
    // Closure that gets called when isMuted changes.
    static var onMuteStateChanged: ((Bool) -> Void)?

    static var isMuted: Bool {
        get { _isMuted }
        set {
            _isMuted = newValue
            onMuteStateChanged?(_isMuted) // Call the closure when the value changes.
            if _isMuted {
                shared.startPeriodicVolumeCheck()
            } else {
                shared.stopPeriodicVolumeCheck()
            }
        }
    }

    private func startPeriodicVolumeCheck(interval: TimeInterval = 0.03) {
        // Invalidate any existing timer
        volumeCheckTimer?.invalidate()
        
        // Set up a new timer
        volumeCheckTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.ensureSystemIsMuted()
        }
    }
    
    private func stopPeriodicVolumeCheck() {
        volumeCheckTimer?.invalidate()
        volumeCheckTimer = nil
        Sound.output.volume = unmuteVolume
        unmuteVolume = -1
    }
        
    // Ensure the system volume is muted
    private func ensureSystemIsMuted() {
        do {
            // Attempt to read the current volume and save it to `unmuteVolume`
            let currentVolume = try Sound.output.readVolume()
            if unmuteVolume == -1 {
                unmuteVolume = currentVolume
            }
            // Attempt to set the volume to 0
            try Sound.output.setVolume(0)
        } catch {
            // If an error occurs, it's caught here. You can decide how to handle it.
            print("An error occurred while trying to mute the system volume: \(error)")
        }
    }

    
}
