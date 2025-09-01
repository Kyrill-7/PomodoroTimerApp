import AVFoundation

final class SoundManager: ObservableObject {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?

    @Published var isPlaying: Bool = false

    private init() {}

    func playCompletion() {
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "wav") else {
            print("⚠️ Missing ding.wav in bundle.")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
        } catch {
            print("Sound error: \(error)")
        }
    }

    func stopSound() {
        player?.stop()
        isPlaying = false
    }
}
