import SwiftUI

struct PodcastListView: View {
    @State private var searchQuery = ""
    @State private var podcasts: [Podcast] = []
    @State private var selectedPodcast: Podcast?
    @State private var isShowingDetailView = false
    @State private var isLoading = false // Track loading state
    @Namespace private var namespace

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    TextField("Search", text: $searchQuery, onCommit: fetchPodcasts)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(EdgeInsets(top: 20, leading: 10, bottom: 10, trailing: 10))
                        .font(Font.custom("MinecraftSevenCyrillicrussian", size: 16))
                        .disabled(isLoading) // Disable search bar when loading

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
