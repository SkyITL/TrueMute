import SwiftUI
import HotKey
import Foundation
import Combine

class HotKeyConfiguration: ObservableObject {
    @Published var selectedKey: Key = .r
    @Published var modifiers: NSEvent.ModifierFlags = [.command, .option]
}

@main
struct TrueMute: App {
    @NSApplicationDelegateAdaptor(VolumeController.self) var volumeController
    @StateObject private var hotKeyConfig = HotKeyConfiguration()
    
    // Retain the HotKey instance
    static var hotKey: HotKey?
    
    init() {
        setupHotkey()
    }

    var body: some Scene {
            WindowGroup {
                ContentView()
                    .onAppear {
                    NSApp.windows.forEach { $0.close() }
                }
            }
        }
    
    func setupHotkey() {
        TrueMute.hotKey = HotKey(key: .m, modifiers: [.command, .shift])
        TrueMute.hotKey?.keyDownHandler = {
            VolumeController.isMuted.toggle()
        }
    }
    
}


