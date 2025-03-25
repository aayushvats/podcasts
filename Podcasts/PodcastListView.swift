import SwiftUI

struct PodcastListView: View {
    @State private var searchQuery = ""
    @State private var podcasts: [Podcast] = []

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Podcasts...", text: $searchQuery, onCommit: fetchPodcasts)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List(podcasts, id: \.url) { podcast in
                    NavigationLink(destination: PodcastPlayerView(feedUrl: podcast.url)) {
                        Text(podcast.title)
                    }
                }
            }
            .navigationTitle("Podcast Search")
        }
    }

    func fetchPodcasts() {
        PodcastService.shared.searchPodcasts(query: searchQuery) { results in
            if let results = results {
                podcasts = results
            }
        }
    }
}
