import SwiftUI

@main
struct PodcastsApp: App {
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some Scene {
        WindowGroup {
            PodcastListView()
                .environmentObject(audioManager)
        }
    }
}
