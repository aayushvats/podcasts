import SwiftUI

struct PodcastListView: View {
    @State private var searchQuery = ""
    @State private var podcasts: [Podcast] = []

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Podcasts...", text: $searchQuery, onCommit: fetchPodcasts)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .font(Font.custom("MinecraftSevenCyrillicrussian", size: 16))

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(podcasts, id: \.url) { podcast in
                            NavigationLink(destination: PodcastDetailsView(
                                feedUrl: podcast.url,
                                title: podcast.title,
                                artwork: podcast.artwork)) {
                                VStack {
                                    AsyncImage(url: URL(string: podcast.artwork)) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150, height: 150)
                                                .clipped()
                                        } else if phase.error != nil {
                                            Color.gray
                                                .frame(width: 150, height: 150)
                                        } else {
                                            ProgressView()
                                                .frame(width: 150, height: 150)
                                        }
                                    }

                                    Text(podcast.title)
                                        .font(Font.custom("MinecraftSevenCyrillicrussian", size: 15))
                                        .multilineTextAlignment(.center)
                                        .frame(width: 150)
                                        .lineLimit(2)

                                    Text(podcast.author)
                                        .font(Font.custom("MinecraftSevenCyrillicrussian", size: 12))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 150)
                                        .lineLimit(1)
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
    }

    func fetchPodcasts() {
        PodcastService.shared.searchPodcasts(query: searchQuery) { results in
            if let results = results {
                podcasts = results
            }
        }
    }
}
