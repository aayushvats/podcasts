import SwiftUI

struct PodcastCardView: View {
    let podcast: Podcast
    let namespace: Namespace.ID

    var body: some View {
        VStack {
//            Image("Vinyl Disk")
//                .resizable()
//                .scaledToFit()
//                .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
//                .frame(width: 150, height: 150)
            Image(uiImage: (convertToUIImage(from: podcast.artworkData) ?? UIImage(named: "Vinyl Disk"))!)
                .resizable()
                .scaledToFit()
                .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
                .frame(width: 150, height: 150)
//            CachedAsyncImage(url: URL(string: podcast.artwork)) { image in
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
//                    .frame(width: 150, height: 150)
////                    .clipShape(RoundedRectangle(cornerRadius: 10))
//            } placeholder: {
//                ProgressView()
//                    .frame(width: 150, height: 150)
//            }

            Text(podcast.title)
                .font(.custom("MinecraftSevenCyrillicrussian", size: 15))
                .multilineTextAlignment(.center)
                .frame(width: 150)
                .lineLimit(2)
                .matchedGeometryEffect(id: "title_\(podcast.url)", in: namespace)

            Text(podcast.author)
                .font(.custom("MinecraftSevenCyrillicrussian", size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(width: 150)
                .lineLimit(1)
                .matchedGeometryEffect(id: "author_\(podcast.url)", in: namespace)
        }
    }
}

