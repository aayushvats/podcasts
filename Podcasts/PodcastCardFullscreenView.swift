import SwiftUI

struct PodcastFullScreenView: View {
    let podcast: Podcast
    @Binding var isShowingDetailView: Bool
    let namespace: Namespace.ID
    @State private var isAnimating = false

    var body: some View {
        VStack {
//            Image("Vinyl Disk")
//                .resizable()
//                .scaledToFit()
//                .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
//                .frame(width: 300, height: 300)
            Image(uiImage: (convertToUIImage(from: podcast.artworkData) ?? UIImage(named: "Vinyl Disk"))!)
                .resizable()
                .scaledToFit()
                .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
                .frame(width: 300, height: 300)
//            CachedAsyncImage(url: URL(string: podcast.artwork)) { image in
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .matchedGeometryEffect(id: "image_\(podcast.url)", in: namespace)
//                    .frame(width: 300, height: 300)
////                    .clipShape(RoundedRectangle(cornerRadius: 20))
//            } placeholder: {
//                Color.gray
//                    .frame(width: 300, height: 300)
//            }

            Text(podcast.title)
                .font(.custom("MinecraftSevenCyrillicrussian", size: 20))
                .multilineTextAlignment(.center)
                .padding()
                .matchedGeometryEffect(id: "title_\(podcast.url)", in: namespace)
                .opacity(isAnimating ? 1 : 0)
                .scaleEffect(isAnimating ? 1 : 0.5)

            Text(podcast.author)
                .font(.custom("MinecraftSevenCyrillicrussian", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .matchedGeometryEffect(id: "author_\(podcast.url)", in: namespace)
                .opacity(isAnimating ? 1 : 0)
                .scaleEffect(isAnimating ? 1 : 0.5)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
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
}
