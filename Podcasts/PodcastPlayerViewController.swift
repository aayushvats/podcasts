import UIKit
import AVFoundation

class PodcastPlayerViewController: UIViewController {
    var feedUrl: String
    var player: AVPlayer?
    let playPauseButton = UIButton()

    init(feedUrl: String) {
        self.feedUrl = feedUrl
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        fetchEpisodes()
    }

    func setupUI() {
        playPauseButton.setTitle("Play", for: .normal)
        playPauseButton.setTitleColor(.blue, for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)

        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playPauseButton)

        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func fetchEpisodes() {
        RSSParser().parseRSS(url: feedUrl) { episodes in
            if let firstEpisode = episodes.first {
                self.playPodcast(url: firstEpisode.1)
            }
        }
    }

    func playPodcast(url: String) {
        player = AVPlayer(url: URL(string: url)!)
        player?.play()
    }

    @objc func playPauseTapped() {
        player?.timeControlStatus == .playing ? player?.pause() : player?.play()
    }
}

