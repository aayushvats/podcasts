import SwiftUI

struct PodcastFullScreenView: View {
    let podcast: Podcast
    @Binding var isShowingDetailView: Bool
    let namespace: Namespace.ID
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: podcast.artwork)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
                        .frame(width: 250, height: 250)
                        .clipped()
                } else if phase.error != nil {
                    Color.gray
                        .frame(width: 250, height: 250)
                } else {
                    ProgressView()
                        .frame(width: 250, height: 250)
                }
            }
            
            Text(podcast.title)
                .font(Font.custom("MinecraftSevenCyrillicrussian", size: 15))
                .multilineTextAlignment(.center)
                .frame(width: 250)
                .lineLimit(2)
            
            Text(podcast.author)
                .font(Font.custom("MinecraftSevenCyrillicrussian", size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(width: 250)
                .lineLimit(1)
        }
    }
}
