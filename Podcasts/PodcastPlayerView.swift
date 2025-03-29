import SwiftUI
import AVKit

struct PodcastPlayerView: View {
    let namespace: Namespace.ID
    let title: String
    let episodeTitle: String
    let audioUrl: String
    let dismissAction: () -> Void
    @State private var player: AVPlayer?
    @State private var playerTime: Double = 0.0
    @State private var duration: Double = 1.0
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Text(episodeTitle)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                Spacer()
                Button(action: dismissAction) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(10)
                }
            }
            .padding()
            
            Spacer()
            
            ZStack {
                Image("Vinyl Player")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 190)
                Image("Vinyl Disk")
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: "vinyl_disk_\(title)", in: namespace)
                    .frame(width: 145, height: 145)
            }
            
            Spacer()
            
            // Progress Bar
            Slider(value: $playerTime, in: 0...duration, onEditingChanged: { editing in
                if !editing {
                    seek(to: playerTime)
                }
            })
            .padding(.horizontal)
            .accentColor(.blue)
            
            // Player Controls
            HStack(spacing: 40) {
                Button(action: { seekRelative(-15) }) {
                    Image(systemName: "gobackward.15")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.white)
                }
                
                Button(action: { togglePlayPause() }) {
                    Image(systemName: player?.timeControlStatus == .playing ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                }
                
                Button(action: { seekRelative(15) }) {
                    Image(systemName: "goforward.15")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical)
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            let url = URL(string: audioUrl)!
            player = AVPlayer(url: url)
            setupPlayer()
        }
    }
    
    func togglePlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else {
                player.play()
            }
        }
    }
    
    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
    }
    
    func seekRelative(_ seconds: Double) {
        if let player = player {
            let currentTime = player.currentTime().seconds
            let newTime = max(0, min(duration, currentTime + seconds))
            seek(to: newTime)
        }
    }
    
    func setupPlayer() {
        Task {
            if let durationTime = try? await player?.currentItem?.asset.load(.duration) {
                duration = CMTimeGetSeconds(durationTime)
            }
        }
        
        // Observe player time changes
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let player = player {
                playerTime = player.currentTime().seconds
            }
        }
    }
}
