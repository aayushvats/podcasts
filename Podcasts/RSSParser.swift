import Foundation

class RSSParser: NSObject, XMLParserDelegate {
    var episodes: [(title: String, audioURL: String)] = []
    var currentElement = ""
    var currentTitle = ""
    var currentAudioURL = ""

    func parseRSS(url: String, completion: @escaping ([(String, String)]) -> Void) {
        guard let feedURL = URL(string: url) else { return }
        let parser = XMLParser(contentsOf: feedURL)!
        parser.delegate = self
        parser.parse()
        completion(episodes)
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        if elementName == "enclosure", let url = attributeDict["url"] {
            currentAudioURL = url
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "title" {
            currentTitle += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
        if elementName == "item" {
            episodes.append((currentTitle, currentAudioURL))
            currentTitle = ""
            currentAudioURL = ""
        }
    }
}

