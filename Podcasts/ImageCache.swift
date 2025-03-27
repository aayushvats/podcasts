import SwiftUI
import Foundation

class ImageCache {
    static let shared = ImageCache()
    
    private let cache: URLCache
    
    private init() {
        let memoryCapacity = 50 * 1024 * 1024 // 50 MB
        let diskCapacity = 100 * 1024 * 1024 // 100 MB
        cache = URLCache(memoryCapacity: memoryCapacity, 
                         diskCapacity: diskCapacity, 
                         diskPath: nil)
    }
    
    func image(for url: URL) async -> UIImage? {
        let request = URLRequest(url: url)
        
        // Check cache first
        if let cachedResponse = cache.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            return image
        }
        
        // If not in cache, download the image
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let image = UIImage(data: data) else {
                return nil
            }
            
            // Store in cache
            let cachedResponse = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedResponse, for: request)
            
            return image
        } catch {
            print("Image download error: \(error)")
            return nil
        }
    }
}
