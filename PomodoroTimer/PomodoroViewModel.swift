import Foundation
import Combine

final class PomodoroViewModel: ObservableObject {
    // MARK: - Published State
    @Published var timeRemaining: Int = 0
    @Published var phase: PomodoroPhase = .focus
    @Published var isRunning: Bool = false
    @Published var completedSessions: Int = 0

    // MARK: - Configurable Durations (seconds)
    @Published var focusDuration: Int = 25 * 60 { didSet { persistDurations(); updateRemainingIfNeeded(for: .focus) } }
    @Published var shortBreakDuration: Int = 5 * 60 { didSet { persistDurations(); updateRemainingIfNeeded(for: .shortBreak) } }
    @Published var longBreakDuration: Int = 15 * 60 { didSet { persistDurations(); updateRemainingIfNeeded(for: .longBreak) } }

    // Limits for live adjustments
    let minSeconds = 60          // 1 minute min
    let maxSeconds = 3 * 60 * 60 // 3 hours max

    private var timer: AnyCancellable?

    // MARK: - Init
    init() {
        loadDurations()
        phase = .focus
        timeRemaining = focusDuration
    }

    // MARK: - Timer Controls
    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pauseTimer() {
        isRunning = false
        timer?.cancel()
    }

    func resetTimer() {
        pauseTimer()
        switch phase {
        case .focus:
            timeRemaining = focusDuration
        case .shortBreak:
            timeRemaining = shortBreakDuration
        case .longBreak:
            timeRemaining = longBreakDuration
        }
    }

    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            return
        }

        // Completed current phase
        pauseTimer()
        SoundManager.shared.playCompletion()

        switch phase {
        case .focus:
            completedSessions += 1
            if completedSessions % 4 == 0 {
                phase = .longBreak
                timeRemaining = longBreakDuration
            } else {
                phase = .shortBreak
                timeRemaining = shortBreakDuration
            }
        case .shortBreak, .longBreak:
            phase = .focus
            timeRemaining = focusDuration
        }
    }

    // MARK: - Live adjustment of remaining time
    func increaseRemaining(by seconds: Int) {
        timeRemaining = min(timeRemaining + seconds, maxSeconds)
    }

    func decreaseRemaining(by seconds: Int) {
        timeRemaining = max(timeRemaining - seconds, 0)
    }

    // MARK: - Helpers
    private func updateRemainingIfNeeded(for target: PomodoroPhase) {
        guard phase == target, !isRunning else { return }
        switch target {
        case .focus:      timeRemaining = focusDuration
        case .shortBreak: timeRemaining = shortBreakDuration
        case .longBreak:  timeRemaining = longBreakDuration
        }
    }

    // MARK: - Persistence
    private func persistDurations() {
        let defaults = UserDefaults.standard
        defaults.set(focusDuration, forKey: "focusDuration")
        defaults.set(shortBreakDuration, forKey: "shortBreakDuration")
        defaults.set(longBreakDuration, forKey: "longBreakDuration")
    }

    private func loadDurations() {
        let defaults = UserDefaults.standard
        let f = defaults.integer(forKey: "focusDuration")
        let s = defaults.integer(forKey: "shortBreakDuration")
        let l = defaults.integer(forKey: "longBreakDuration")

        // If first run, integers will be 0 — keep defaults
        if f > 0 { focusDuration = f }
        if s > 0 { shortBreakDuration = s }
        if l > 0 { longBreakDuration = l }
    }

    // MARK: - Formatting
    var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var phaseText: String { phase.displayName }
}
