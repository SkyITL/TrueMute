import SwiftUI
import AppKit

@main
struct YourAppName: App {
    @NSApplicationDelegateAdaptor(VolumeController.self) var volumeController


    init() {
        setupHotkey()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    func setupHotkey() {
        print("Setting up hotkey")
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            print("Key event captured: \(event.charactersIgnoringModifiers ?? "") with modifiers: \(event.modifierFlags)")
            if event.modifierFlags.intersection([.command, .shift]) == [.command, .shift] && event.charactersIgnoringModifiers == "M" {
                if VolumeController.isMuted == false{
                    VolumeController.isMuted = true
                }
                else{
                    VolumeController.isMuted = false
                }
                return nil
            }
            return event
        }
    }
}



