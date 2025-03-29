import SwiftUI

struct PodcastFullScreenView: View {
    let podcast: Podcast
    @Binding var isShowingDetailView: Bool
    let namespace: Namespace.ID
    @EnvironmentObject var audioManager: AudioManager
    
    @State private var isAnimating = false
    @State private var isLoadingEpisodes = true
    @State private var episodes: [Episode] = []
    @State private var showStackedImages = false
    @State private var rotationAngle: Double = -100
    @State private var vinylOffset: CGFloat = 0
    @State private var selectedEpisode: Episode?  // <-- Track selected episode

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                // Close Button
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(10)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                isAnimating = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                withAnimation(.spring()) {
                                    isShowingDetailView = false
                                }
                            }
                        }
                }

                // Podcast Artwork
                HStack {
                    if showStackedImages {
                        ZStack {
                            Image("Vinyl Disk")
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: "vinyl_disk_\(podcast.title)", in: namespace)
                                .frame(width: 145, height: 145)
                                .rotationEffect(.degrees(rotationAngle))
                                .offset(x: vinylOffset)
                                .zIndex(0)
//                                .animation(.easeInOut(duration: 0.8), value: vinylOffset)

                            Image(uiImage: (convertToUIImage(from: podcast.artworkData) ?? UIImage(named: "Vinyl Disk"))!)
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
                                .frame(width: 150, height: 150)
                                .zIndex(2)
                        }
                    } else {
                        Image(uiImage: (convertToUIImage(from: podcast.artworkData) ?? UIImage(named: "Vinyl Disk"))!)
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
                            .frame(width: 150, height: 150)
                    }
                }
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Podcast Title & Author
                Text(podcast.title)
                    .font(.custom("MinecraftSevenCyrillicrussian", size: 20))
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 2, trailing: 0))
                Text(podcast.author)
                    .font(.custom("MinecraftSevenCyrillicrussian", size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)

                // Episodes Section
                Text("Episodes")
                    .font(.custom("MinecraftSevenCyrillicrussian", size: 15))
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 15, leading: 20, bottom: 8, trailing: 0))

                if isLoadingEpisodes {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(episodes, id: \.title) { episode in
                                Button(action: {
                                    audioManager.playEpisode(episode: episode, podcast: podcast)
                                    withAnimation(.smooth(duration: 1)) {
                                        selectedEpisode = episode
                                    }
                                }) {
                                    Text(episode.title)
                                        .font(.custom("MinecraftSevenCyrillicrussian", size: 16))
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color.black)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showStackedImages = true
                    vinylOffset = 0
                    getEpisodes()
                    withAnimation(.easeInOut(duration: 0.8)) {
                        rotationAngle = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            vinylOffset = UIScreen.main.bounds.width * 0.25
                        }
                    }
                }
            }

            // Place the PodcastPlayerView inside the same ZStack
            if let episode = selectedEpisode {
                PodcastPlayerView(
                    namespace: namespace,
//                    title: podcast.title,
//                    episodeTitle: episode.title,
//                    audioUrl: episode.audioURL,
//                    podcastGuid: podcast.podcastGuid,
                    dismissAction: {
                        withAnimation(.spring()) {
                            selectedEpisode = nil
                        }
                    },
                    isPlayedNow: true
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }

    func getEpisodes() {
        parseEpisodes { episodes in
            print(episodes)
            self.episodes = episodes.map {
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
            isLoadingEpisodes = false
        }
    }

    func parseEpisodes(completion: @escaping ([(title: String, audioURL: String)]) -> Void) {
        RSSParser().parseRSS(url: podcast.url) { episodes in
            DispatchQueue.main.async {
                completion(episodes)
            }
        }
    }
}
