import SwiftUI

struct PodcastFullScreenView: View {
    let podcast: Podcast
    @Binding var isShowingDetailView: Bool
    let namespace: Namespace.ID
    @State private var isAnimating = false
    @State private var isLoadingEpisodes = true
    @State private var episodes: [Episode] = []
    @State private var showStackedImages = false
    @State private var rotationAngle: Double = -100
    @State private var vinylOffset: CGFloat = 0

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
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
                HStack {
                    if showStackedImages {
                        ZStack {
                            Image("Vinyl Disk")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 145, height: 145)
                                .rotationEffect(.degrees(rotationAngle))
                                .offset(x: vinylOffset)
                                .zIndex(0)
                                .animation(.easeInOut(duration: 0.8), value: vinylOffset)
                            
                            Image(uiImage: (convertToUIImage(from: podcast.artworkData) ?? UIImage(named: "Vinyl Disk"))!)
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
                                .frame(width: 150, height: 150)
                                .zIndex(1)
                        }
                    }
                    else {
                        Image(uiImage: (convertToUIImage(from: podcast.artworkData) ?? UIImage(named: "Vinyl Disk"))!)
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
                            .frame(width: 150, height: 150)
                    }
                }
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(podcast.title)
                    .font(.custom("MinecraftSevenCyrillicrussian", size: 20))
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 2, trailing: 0))
                Text(podcast.author)
                    .font(.custom("MinecraftSevenCyrillicrussian", size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                
                Text("Episodes")
                    .font(.custom("MinecraftSevenCyrillicrussian", size: 15))
                //                .foregroundColor(.gray)
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
                                NavigationLink(destination: PodcastPlayerView(episodeTitle: episode.title, audioUrl: episode.audioURL)) {
                                    Text(episode.title)
                                        .font(.headline)
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
        }
    }
    
    func getEpisodes() {
        parseEpisodes { episodes in
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
            print(self.episodes)
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
