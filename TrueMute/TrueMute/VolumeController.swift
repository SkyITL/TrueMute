//
//  VolumeController.swift
//  TrueMute
//
//  Created by Sky Liu on 4/9/24.
//

import AppKit
import ISSoundAdditions
import HotKey
import Foundation
import Cocoa
import SwiftUI

class VolumeController: NSObject, NSApplicationDelegate {
    static let shared = VolumeController()
    private var volumeCheckTimer: Timer?
    private static var _isMuted: Bool = false
    private var unmuteVolume: Float = -1
    static var onMuteStateChanged: ((Bool) -> Void)?
    private var muteIndicatorWindow: MuteIndicatorWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
            NSApp.setActivationPolicy(.accessory) // Hide the app from the Dock
        }

    static var isMuted: Bool {
        get { _isMuted }
        set {
            _isMuted = newValue
            onMuteStateChanged?(_isMuted)
            DispatchQueue.main.async {
                if _isMuted {
                    shared.startPeriodicVolumeCheck()
                    shared.showMuteIndicator(status: "mute")
                } else {
                    shared.stopPeriodicVolumeCheck()
                    shared.showMuteIndicator(status: "unmute")
                }
            }
        }
    }
    
    private func startPeriodicVolumeCheck(interval: TimeInterval = 0.03) {
        volumeCheckTimer?.invalidate()
        volumeCheckTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.ensureSystemIsMuted()
            }
        }
    }
    
    private func stopPeriodicVolumeCheck() {
        do {
            try Sound.output.setVolume(unmuteVolume)
        } catch {
            print("An error occurred while trying to mute the system volume: \(error)")
        }
        volumeCheckTimer?.invalidate()
        volumeCheckTimer = nil
    }
    
    private func ensureSystemIsMuted() {
        do {
            let currentVolume = try Sound.output.readVolume()
            if currentVolume > 0 {  // If the volume is not zero, mute it.
                unmuteVolume = currentVolume
                try Sound.output.setVolume(0)
            }
        } catch {
            print("An error occurred while trying to mute the system volume: \(error)")
        }
    }
    
    private func showMuteIndicator(status: String) {
            DispatchQueue.main.async {
                if self.muteIndicatorWindow == nil {
                    self.muteIndicatorWindow = MuteIndicatorWindow(contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
                                                                   styleMask: .borderless,
                                                                   backing: .buffered, defer: false)
                    self.muteIndicatorWindow?.center()
                }
                
                self.muteIndicatorWindow?.updateStatus(status: status)
            }
        }

}

class MuteIndicatorWindow: NSWindow {
    private var fadeOutTimer: Timer?

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.hasShadow = true
        
        // Adjust the level and collection behavior
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)) + 1)
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        
        // Center the window initially
        self.center()
    }

    func updateStatus(status: String) {
        DispatchQueue.main.async {
            let rootView = status == "mute" ? AnyView(MuteIndicatorView()) : AnyView(UnmuteIndicatorView())
            self.contentView = NSHostingView(rootView: rootView)
            self.alphaValue = 1 // Reset transparency before showing.
            self.makeKeyAndOrderFront(nil)
            self.startFadeOut()
        }
    }
    
    func startFadeOut() {
        fadeOutTimer?.invalidate() // Invalidate any existing timer
        fadeOutTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.8
                self?.animator().alphaValue = 0
            }, completionHandler: {
            })
        }
    }
}

struct MuteIndicatorView: View {
    var body: some View {
        Image(systemName: "speaker.slash.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
    }
}

struct UnmuteIndicatorView: View {
    var body: some View {
        Image(systemName: "speaker.2.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
    }
}
