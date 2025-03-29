import SwiftUI
import AVKit

struct PodcastPlayerView: View {
    let namespace: Namespace.ID
    let title: String
    let episodeTitle: String
    let audioUrl: String
    let podcastGuid: String
    let dismissAction: () -> Void
    @State private var player: AVPlayer?
    @State private var playerTime: Double = 0.0
    @State private var duration: Double = 1.0
    @State private var rotationAngle: Double = 0
    @State private var isPlaying: Bool = false
    @State private var rotationTimer: Timer?
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
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
                    .frame(width: UIScreen.main.bounds.width - 40)
                    .zIndex(0)
                Image("Vinyl Disk")
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(rotationAngle))
                    .matchedGeometryEffect(id: "vinyl_disk_\(title)", in: namespace)
                    .frame(width: UIScreen.main.bounds.width - 178)
                    .offset(x: UIScreen.main.bounds.width * -0.092, y: UIScreen.main.bounds.width * -0.004)
                    .zIndex(1)
                Image("Vinyl Pin")
                    .resizable()
                    .scaledToFit()
                    .frame(height: UIScreen.main.bounds.width - 210)
                    .offset(x: UIScreen.main.bounds.width * 0.175, y: -35)
                    .zIndex(2)
            }
            
            Spacer()
            
            // Progress Bar
            Slider(value: $playerTime, in: 0...duration, onEditingChanged: { editing in
                if !editing {
                    seek(to: playerTime)
                }
            })
            .padding(.horizontal, 20)
            .accentColor(.blue)
            
            // Timestamp
            HStack {
                Text(formatTime(playerTime))
                    .foregroundColor(.white)
                Spacer()
                Text(formatTime(duration))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            
            // Player Controls (Centered)
            HStack(spacing: 40) {
                Button(action: { seekRelative(-15) }) {
                    Image(systemName: "gobackward.15")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.white)
                }
                
                Button(action: { togglePlayPause() }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
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
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
            
//            Spacer()
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            let url = URL(string: audioUrl)!
            player = AVPlayer(url: url)
            setupPlayer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                rotationTimer?.invalidate()
                rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
                    rotationAngle += 0.1 // Slower rotation
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                rotationTimer?.invalidate()
            }
        }
    }
    
    func togglePlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
                isPlaying = false
                stopRotating()
            } else {
                player.play()
                isPlaying = true
                startRotating()
            }
        }
    }
    
    func startRotating() {
        rotationTimer?.invalidate()
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            rotationAngle += 1 // Slower rotation
        }
    }
    
    func stopRotating() {
        rotationTimer?.invalidate()
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
    
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
