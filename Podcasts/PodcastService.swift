import Foundation
import CommonCrypto
import SwiftUI

extension String {
  func sha1() -> String {
  let data = Data(self.utf8)
  var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
      data.withUnsafeBytes {
      _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
  }
  let hexBytes = digest.map { String(format: "%02hhx", $0) }
      return hexBytes.joined()
  }
}

struct Podcast: Codable, Hashable {
    let id: Int
    let title: String
    let url: String
    let originalUrl: String
    let link: String
    let description: String
    let author: String
    let ownerName: String
    let image: String
    let artwork: String
    let language: String
    let explicit: Bool
    let podcastGuid: String
    let medium: String
    let episodeCount: Int
    var artworkData: [UInt8]? // New property to store image data as UInt8 array
}


struct PodcastResponse: Codable {
    let feeds: [Podcast]
}

struct Episode: Identifiable {
    let id = UUID() // Unique identifier for each episode
    let title: String
    let audioURL: String
}

class PodcastService {
    static let shared = PodcastService()
    private let apiKey = "XSSTN3RL8VL7PPKAFSLS"
    private let apiSecret = "QBay$9BAAEPCBtsEk$Dga3dEuN97#qG8UzByFARQ"
    private let baseUrl = "https://api.podcastindex.org/api/1.0/search/byterm"
    
    func searchPodcasts(query: String, completion: @escaping ([Podcast]?) -> Void) {
        let apiHeaderTime = String(Int(Date().timeIntervalSince1970))
        let hashInput = apiKey + apiSecret + apiHeaderTime
        let hash = hashInput.sha1()
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseUrl)?q=\(encodedQuery)") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.httpMethod = "GET"
        request.addValue("MyUniquePodcastApp/1.0 (contact@example.com)", forHTTPHeaderField: "User-Agent")
        request.addValue(apiKey, forHTTPHeaderField: "X-Auth-Key")
        request.addValue(apiHeaderTime, forHTTPHeaderField: "X-Auth-Date")
        request.addValue(hash, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                print("Failed with status: \(String(describing: response))")
                completion(nil)
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(PodcastResponse.self, from: data)
                
                // Create a mutable copy of the podcasts array
                var podcasts = decodedResponse.feeds
                
                // Fetch images for each podcast
                let group = DispatchGroup()
                for i in podcasts.indices {
                    group.enter()
                    self.fetchImageData(from: podcasts[i].artwork) { imageData in
                        if let imageData = imageData {
                            podcasts[i] = Podcast(
                                id: podcasts[i].id,
                                title: podcasts[i].title,
                                url: podcasts[i].url,
                                originalUrl: podcasts[i].originalUrl,
                                link: podcasts[i].link,
                                description: podcasts[i].description,
                                author: podcasts[i].author,
                                ownerName: podcasts[i].ownerName,
                                image: podcasts[i].image,
                                artwork: podcasts[i].artwork,
                                language: podcasts[i].language,
                                explicit: podcasts[i].explicit,
                                podcastGuid: podcasts[i].podcastGuid,
                                medium: podcasts[i].medium,
                                episodeCount: podcasts[i].episodeCount,
                                artworkData: Array(imageData) // Convert Data to [UInt8]
                            )
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(podcasts)
                }
            } catch {
                print("Decoding Error: \(error)")
                completion(nil)
            }
        }.resume()
    }

    private func fetchImageData(from urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Image Fetch Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(data)
        }.resume()
    }
}

/// Converts [UInt8] to UIImage
func convertToUIImage(from bytes: [UInt8]?) -> UIImage? {
    if(bytes == nil) {
        return UIImage(named: "Vinyl Disk")
    }else{
        let data = Data(bytes ?? [])
        return UIImage(data: data)
    }
}
