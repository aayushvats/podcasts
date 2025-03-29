import Foundation
import AVKit
import Combine // Needed for @Published and ObservableObject

class AudioManager: ObservableObject {
    static let shared = AudioManager() // Singleton or pass via Environment

    @Published var player: AVPlayer?
    @Published var currentEpisode: Episode?
    @Published var currentPodcast: Podcast? // Keep track of the parent podcast too
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0

    private var timeObserverToken: Any?
    private var cancellables = Set<AnyCancellable>()

    private init() { // Make init private for singleton
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio Session Active")
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    func playEpisode(episode: Episode, podcast: Podcast) {
        // Stop existing player if any
        stop()

        guard let url = URL(string: episode.audioURL) else {
            print("Invalid URL for episode: \(episode.title)")
            return
        }

        currentEpisode = episode
        currentPodcast = podcast
        player = AVPlayer(url: url)

        // Observe player readiness and duration
        player?.publisher(for: \.status)
            .filter { $0 == .readyToPlay }
            .sink { [weak self] _ in
                self?.duration = self?.player?.currentItem?.duration.seconds ?? 0.0
                self?.player?.play()
                self?.isPlaying = true
                self?.addPeriodicTimeObserver()
            }
            .store(in: &cancellables)

         // Observe player end time
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            .sink { [weak self] _ in
                self?.isPlaying = false
                self?.currentTime = 0 // Reset time or move to next?
                // Optionally: self?.stop() // or self?.playNext()
            }
            .store(in: &cancellables)

        // Observe playing state directly
        player?.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                switch status {
                case .playing:
                    self?.isPlaying = true
                case .paused, .waitingToPlayAtSpecifiedRate:
                    self?.isPlaying = false
                @unknown default:
                    self?.isPlaying = false
                }
            }
            .store(in: &cancellables)
    }

    func togglePlayPause() {
        guard player != nil else { return }
        if isPlaying {
            player?.pause()
        } else {
            // Check if playback finished, if so, seek to start before playing
            if currentTime >= duration - 1.0 { // Account for slight inaccuracies
                 seek(to: 0)
            }
            player?.play()
        }
        // isPlaying state should update via the timeControlStatus observer
    }

    func stop() {
        player?.pause()
        removePeriodicTimeObserver()
        player = nil
        currentEpisode = nil
        currentPodcast = nil
        isPlaying = false
        currentTime = 0.0
        duration = 0.0
        cancellables.forEach { $0.cancel() } // Cancel observers
        cancellables.removeAll()
    }

    func seek(to time: Double) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: time, preferredTimescale: 600) // Higher precision
        player.seek(to: targetTime)
    }

    func seekRelative(_ seconds: Double) {
        guard player != nil else { return }
        let newTime = max(0, min(duration, currentTime + seconds))
        seek(to: newTime)
    }

    private func addPeriodicTimeObserver() {
        removePeriodicTimeObserver() // Ensure only one observer exists
        guard let player = player else { return }

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            // Update duration in case it wasn't ready initially
            if self?.duration == 0.0 || self?.duration.isNaN ?? true {
                 self?.duration = self?.player?.currentItem?.duration.seconds ?? 0.0
            }
        }
    }

    private func removePeriodicTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    func formatTime(_ time: Double) -> String {
        guard !time.isNaN && !time.isInfinite else {
            return "00:00"
        }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
