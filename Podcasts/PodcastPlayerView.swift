import SwiftUI
import AVKit

struct PodcastPlayerView: View {
    @EnvironmentObject var audioManager: AudioManager
    let namespace: Namespace.ID
//    let title: String
//    let episodeTitle: String
//    let audioUrl: String
    var dismissAction: (() -> Void)? = nil
    var isPlayedNow: Bool = false
//    @State private var player: AVPlayer?
//    @State private var playerTime: Double = 0.0
//    @State private var duration: Double = 1.0
    @State private var rotationAngle: Double = 0
//    @State private var isPlaying: Bool = false
    @State private var rotationTimer: Timer?
    
    private var podcastTitle: String { audioManager.currentPodcast?.title ?? "Podcast" }
    private var episodeTitle: String { audioManager.currentEpisode?.title ?? "Episode" }
//    private var artworkData: Data? { audioManager.currentPodcast?.artworkData } // Need artwork in AudioManager or pass Podcast
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                                    Text(podcastTitle) // Use computed property
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(episodeTitle) // Use computed property
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                Spacer()
                if isPlayedNow {
                    Button(action: dismissAction!) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(10)
                    }
                } else {
                    // Add a chevron down or similar if it's part of a sheet
                     Button {
                         // Standard dismiss environment action could be used if presented via .sheet/.fullScreenCover
                     } label: {
                         Image(systemName: "chevron.down")
                            .resizable().scaledToFit().frame(width: 20)
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                     }
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
                    .matchedGeometryEffect(id: "vinyl_disk_\(podcastTitle)", in: namespace)
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
            Slider(value: $audioManager.currentTime, in: 0...(audioManager.duration > 0 ? audioManager.duration : 1.0), onEditingChanged: { editing in
                if !editing {
                    audioManager.seek(to: audioManager.currentTime)
                }
            })
            .padding(.horizontal, 20)
            .accentColor(.blue)
            .disabled(audioManager.duration <= 0 || audioManager.duration.isNaN)
            
            // Timestamp
            HStack {
                            Text(audioManager.formatTime(audioManager.currentTime))
                                .foregroundColor(.white)
                            Spacer()
                            Text(audioManager.formatTime(audioManager.duration))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
            
            // Player Controls (Centered)
            HStack(spacing: 40) {
                Button(action: { audioManager.seekRelative(-15) }) {
                    Image(systemName: "gobackward.15")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.white)
                }
                
                Button(action: { audioManager.togglePlayPause() }) {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                }
                
                Button(action: { audioManager.seekRelative(15) }) {
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
//        .onAppear {
//            let url = URL(string: audioUrl)!
//            player = AVPlayer(url: url)
//            setupPlayer()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                rotationTimer?.invalidate()
//                rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
//                    rotationAngle += 0.1 // Slower rotation
//                }
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                rotationTimer?.invalidate()
//            }
//        }
        .onAppear(perform: handleRotation)
        .onChange(of: audioManager.isPlaying) { _ in handleRotation() }
        .onDisappear { stopRotating() }
    }
    func handleRotation() {
            if audioManager.isPlaying {
                startRotating()
            } else {
                stopRotating()
            }
        }

        func startRotating() {
             guard rotationTimer == nil else { return } // Prevent multiple timers
             rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in // Adjust speed if needed
                 rotationAngle += 1
             }
         }

         func stopRotating() {
             rotationTimer?.invalidate()
             rotationTimer = nil
         }
}
