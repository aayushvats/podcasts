import Foundation
import CommonCrypto

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

struct Podcast: Codable {
    let title: String
    let url: String
}

struct PodcastResponse: Codable {
    let feeds: [Podcast]
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
        
        print("Requesting: \(url)")
        print("X-Auth-Date: \(apiHeaderTime)")
        print("Hash Input: \(hashInput)")
        print("Computed Hash: \(hash)")
        
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

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(nil)
                return
            }
            
            print("Response Code: \(httpResponse.statusCode)")

            guard let data = data, httpResponse.statusCode == 200 else {
                print("Failed with status: \(httpResponse)")
                completion(nil)
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(PodcastResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.feeds)
                }
            } catch {
                print("Decoding Error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
