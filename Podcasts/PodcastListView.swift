import SwiftUI

struct PodcastListView: View {
    @State private var searchQuery = ""
    @State private var podcasts: [Podcast] = []

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Podcasts...", text: $searchQuery, onCommit: fetchPodcasts)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))

                List(podcasts, id: \.url) { podcast in
                    NavigationLink(destination: PodcastDetailsView(
                        feedUrl: podcast.url,
                        title: podcast.title)) {
                        VStack(alignment: .leading) {
                            Text(podcast.title).font(.headline)
                            Text(podcast.author).font(.caption)
                        }
                        
                    }
                }
            }
            .navigationTitle("Podcasts")
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
