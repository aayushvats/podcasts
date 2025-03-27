import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder var content: (Image) -> Content
    @ViewBuilder var placeholder: () -> Placeholder
    
    @State private var currentImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = currentImage {
                content(Image(uiImage: image))
            } else if isLoading {
                placeholder()
            } else {
                placeholder()
            }
        }
        .task {
            guard let url = url else { return }
            
            isLoading = true
            currentImage = await ImageCache.shared.image(for: url)
            isLoading = false
        }
    }
}
