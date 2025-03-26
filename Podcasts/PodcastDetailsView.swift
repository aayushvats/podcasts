import SwiftUI
import AVKit

struct PodcastDetailsView: View {
    let feedUrl: String
    let title: String
    @State private var episodes: [Episode] = []

    var body: some View {
        VStack {
            List(episodes) { episode in
                NavigationLink(destination: PodcastPlayerView(episodeTitle: episode.title, audioUrl: episode.audioURL)) {
                    Text(episode.title)
                }
            }.navigationTitle(title).navigationBarTitleDisplayMode(.automatic)
        }
        .onAppear {
            fetchEpisodes{episodes in
                self.episodes = episodes.map{
                    Episode(
                        title: ($0.0.trimmingCharacters(in: .whitespacesAndNewlines)
                                .components(separatedBy: "\n").last ?? "")
                                .trimmingCharacters(in: .whitespacesAndNewlines) == ""
                                    ? $0.0
                                    : $0.0.trimmingCharacters(in: .whitespacesAndNewlines)
                                        .components(separatedBy: "\n").last!
                                        .trimmingCharacters(in: .whitespacesAndNewlines),
                        audioURL: $0.1)
                }
                print(self.episodes)
            }
        }
    }

    func fetchEpisodes(completion: @escaping ([(title: String, audioURL: String)]) -> Void) {
        RSSParser().parseRSS(url: feedUrl) { episodes in
            DispatchQueue.main.async {
                completion(episodes)
            }
        }
    }
}

