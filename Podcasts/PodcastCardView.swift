import SwiftUI

struct PodcastCardView: View {
    let podcast: Podcast
    let namespace: Namespace.ID
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: podcast.artwork)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
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
