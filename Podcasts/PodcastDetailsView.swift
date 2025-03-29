import SwiftUI
import AVKit

struct PodcastDetailsView: View {
    let namespace: Namespace.ID
    let feedUrl: String
    let title: String
    let artwork: String
    @State private var episodes: [Episode] = []

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: artwork)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(15)
                        .padding()
                } else if phase.error != nil {
                    Color.gray
                        .frame(width: 200, height: 200)
                        .cornerRadius(15)
                        .padding()
                } else {
                    ProgressView()
                        .frame(width: 200, height: 200)
                        .padding()
                }
            }
            List(episodes) { episode in
                NavigationLink(
                    destination: PodcastPlayerView(
                        namespace: namespace,
                        title: title,
                        episodeTitle: episode.title,
                        audioUrl: episode.audioURL,
                        dismissAction: {
                            withAnimation(.spring()) {
//                                selectedEpisode = nil
                            }
                        }
                    )
                ){
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

