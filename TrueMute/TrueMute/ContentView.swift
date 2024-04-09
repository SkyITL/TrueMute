//
//  ContentView.swift
//  TrueMute
//
//  Created by Sky Liu on 4/9/24.
//
import SwiftUI

struct ContentView: View {
    @State private var isMuted: Bool = VolumeController.isMuted
    
    var body: some View {
        VStack {
            Button(isMuted ? "Unmute" : "Mute") {
                VolumeController.isMuted.toggle()
            }
            .scaledToFit()
            .buttonStyle(.bordered)
            Text("You can minimize or close this window. The toggle Hot key is Command + Shift + M.")
        }
        .onAppear {
            // Set the closure to update the local state when isMuted changes.
            VolumeController.onMuteStateChanged = { muted in
                isMuted = muted
            }
        }
    }
}


#Preview {
    ContentView()
}
