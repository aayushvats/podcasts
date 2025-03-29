import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var audioManager: AudioManager
    var onTapAction: () -> Void // Action to perform when tapped (e.g., show full player)

    // Use computed properties for safety
//    private var podcastArtworkData: {}
    private var episodeTitle: String { audioManager.currentEpisode?.title ?? "" }

    var body: some View {
        HStack(spacing: 10) {
            // Artwork
            Image(uiImage: (convertToUIImage(from: audioManager.currentPodcast?.artworkData) ?? UIImage(named: "Vinyl Disk"))!)
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .cornerRadius(4)
                // Optional: Add matchedGeometryEffect if animating from here
                // .matchedGeometryEffect(id: "image_\(audioManager.currentPodcast?.url ?? "")", in: namespace)

            // Title
            Text(episodeTitle)
                .font(.system(size: 14, weight: .medium)) // Adjust font
                .lineLimit(1)
                .foregroundColor(.white)

            Spacer()

            // Controls
            HStack(spacing: 15) {
                 Button {
                     audioManager.seekRelative(-15)
                 } label: {
                     Image(systemName: "gobackward.15")
                         .font(.system(size: 20))
                         .foregroundColor(.white)
                 }

                Button {
                    audioManager.togglePlayPause()
                } label: {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22))
                        .frame(width: 25, height: 25) // Ensure consistent frame size
                        .foregroundColor(.white)
                }

                 Button {
                     audioManager.seekRelative(15)
                 } label: {
                     Image(systemName: "goforward.15")
                         .font(.system(size: 20))
                         .foregroundColor(.white)
                 }
            }
        }
        .padding(EdgeInsets(top: 8, leading: 10, bottom: 40, trailing: 10))
        .frame(height: 100) // Set a fixed height
        .background(Color.black.opacity(0.9)) // Or use a blur effect
        // .background(.ultraThinMaterial) // Alternative background
        .cornerRadius(0) // Make it full width usually
        .contentShape(Rectangle()) // Make the whole area tappable
        .onTapGesture(perform: onTapAction) // Trigger action on tap
    }
}
