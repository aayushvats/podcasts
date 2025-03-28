import SwiftUI

struct PodcastCardView: View {
    let podcast: Podcast
    let namespace: Namespace.ID

    var body: some View {
        VStack {
            Image(uiImage: (convertToUIImage(from: podcast.artworkData) ?? UIImage(named: "Vinyl Disk"))!)
                .resizable()
                .scaledToFit()
                .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
                .frame(width: 150, height: 150)

            Text(podcast.title)
                .font(.custom("MinecraftSevenCyrillicrussian", size: 15))
                .multilineTextAlignment(.center)
                .frame(width: 150)
                .lineLimit(2)

            Text(podcast.author)
                .font(.custom("MinecraftSevenCyrillicrussian", size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(width: 150)
                .lineLimit(1)
        }
    }
}

