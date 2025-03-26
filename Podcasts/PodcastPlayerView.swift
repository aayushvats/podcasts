import SwiftUI
import AVKit

struct PodcastPlayerView: View {
//    let feedUrl: String
    
    let episodeTitle: String
    let audioUrl: String
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack {
            Text(episodeTitle)
                .font(.headline)
                .padding()

            Button(action: {
                togglePlayPause()
            }) {
                Text(player?.timeControlStatus == .playing ? "Pause" : "Play")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            fetchEpisodes()
        }
    }

    func fetchEpisodes() {
//        RSSParser().parseRSS(url: feedUrl) { episodes in
//            if let firstEpisode = episodes.first {
//                episodeTitle = firstEpisode.0
//                audioUrl = firstEpisode.1
                player = AVPlayer(url: URL(string: audioUrl)!)
//            }
//        }
    }

    func togglePlayPause() {
        guard let player = player else { return }
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
}

