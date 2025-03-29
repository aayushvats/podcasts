import SwiftUI

struct PodcastListView: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State private var searchQuery = ""
    @State private var podcasts: [Podcast] = []
    @State private var selectedPodcast: Podcast?
    @State private var isShowingDetailView = false
    @State private var isLoading = false // Track loading state
    @State private var isShowingFullPlayer = false
    @Namespace private var namespace

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    private var bottomPadding: CGFloat {
            audioManager.currentEpisode != nil ? 60 : 0 // Height of MiniPlayerView
        }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                VStack {
                    TextField("Search", text: $searchQuery, onCommit: fetchPodcasts)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(EdgeInsets(top: 20, leading: 10, bottom: 10, trailing: 10))
                        .font(Font.custom("MinecraftSevenCyrillicrussian", size: 16))
                        .disabled(isLoading || isShowingDetailView) // Disable search bar when loading

                    if isLoading {
                        ProgressView("Fetching...")
                            .font(.custom("MinecraftSevenCyrillicrussian", size: 16))
                            .padding()
                    }

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(podcasts, id: \.url) { podcast in
                                PodcastCardView(podcast: podcast, namespace: namespace)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            selectedPodcast = podcast
                                            isShowingDetailView = true
                                        }
                                    }
                            }
                        }
                        .padding()
                        .padding(.bottom, bottomPadding)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Podcasts")
                            .font(Font.custom("MinecraftSevenCyrillicrussian", size: 30))
                    }
                }
            }
            .blur(radius: isShowingDetailView ? 10 : 0)
            .disabled(isShowingDetailView)

            if let podcast = selectedPodcast, isShowingDetailView {
                PodcastFullScreenView(
                    podcast: podcast,
                    isShowingDetailView: $isShowingDetailView,
                    namespace: namespace
                )
                .zIndex(10)
//                .onTapGesture {
//                    withAnimation(.spring()) {
//                        selectedPodcast = nil
//                        isShowingDetailView = false
//                    }
//                }
            }
            
            if audioManager.currentEpisode != nil { // Check if something is playing
                            MiniPlayerView(onTapAction: {
                                withAnimation {
                                    isShowingFullPlayer = true // Trigger the full player sheet
                                }
                            })
                            .transition(.move(edge: .bottom).combined(with: .opacity)) // Animate appearance
                            .zIndex(10) // Ensure it's above the NavigationView content
                        }
            
            
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .sheet(isPresented: $isShowingFullPlayer) { // Or .fullScreenCover
                     // Pass the namespace and EnvironmentObject will handle AudioManager
                    PodcastPlayerView(namespace: namespace) {
                         // Optional dismiss action for the player view itself if needed
                        isShowingFullPlayer = false
                    }
                    .presentationDragIndicator(.visible) // Nice handle for sheet
                }
    }

    func fetchPodcasts() {
        isLoading = true // Start loading

        PodcastService.shared.searchPodcasts(query: searchQuery) { results in
            DispatchQueue.main.async {
                if let results = results {
                    podcasts = results
                }
                isLoading = false // Stop loading
            }
        }
    }
}
