import Foundation

enum PomodoroPhase: String, CaseIterable {
    case focus
    case shortBreak
    case longBreak

    var displayName: String {
        switch self {
        case .focus: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
}
