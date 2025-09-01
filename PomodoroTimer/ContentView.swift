import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PomodoroViewModel()
    @StateObject private var soundManager = SoundManager.shared
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [phaseColor.opacity(0.4), Color(.systemBackground)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {

                    // Phase name
                    Text(viewModel.phaseText)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(phaseColor.gradient)

                    // Progress Ring with Timer
                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 20)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [phaseColor, .pink, .yellow, phaseColor]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.5), value: viewModel.timeRemaining)

                        Text(viewModel.timeString)
                            .font(.system(size: 52, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    .frame(width: 260, height: 260)
                    .shadow(color: phaseColor.opacity(0.3), radius: 12, x: 0, y: 6)

                    // Adjustment buttons
                    VStack(spacing: 12) {
                        Text("Adjust Remaining Time")
                            .font(.headline)

                        HStack(spacing: 12) {
                            pillButton("−1m", colors: [.red, .orange]) { viewModel.decreaseRemaining(by: 60) }
                            pillButton("−10s", colors: [.pink, .purple]) { viewModel.decreaseRemaining(by: 10) }
                            pillButton("+10s", colors: [.blue, .cyan]) { viewModel.increaseRemaining(by: 10) }
                            pillButton("+1m", colors: [.green, .teal]) { viewModel.increaseRemaining(by: 60) }
                        }
                    }

                    // Start / Pause / Reset
                    HStack(spacing: 16) {
                        mainButton(
                            title: viewModel.isRunning ? "Pause" : "Start",
                            colors: viewModel.isRunning ? [.orange, .red] : [.blue, .purple]
                        ) {
                            viewModel.isRunning ? viewModel.pauseTimer() : viewModel.startTimer()
                        }

                        mainButton(
                            title: "Reset",
                            colors: [.gray, .black]
                        ) {
                            viewModel.resetTimer()
                        }
                    }

                    // Stop sound button if playing
                    if soundManager.isPlaying {
                        mainButton(title: "Stop Sound", colors: [.pink, .red]) {
                            soundManager.stopSound()
                        }
                        .transition(.scale)
                    }

                    // Sessions completed
                    Text("✅ Completed Focus Sessions: \(viewModel.completedSessions)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Pomodoro")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .imageScale(.large)
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
        }
    }

    // MARK: - UI Helpers
    private var progress: CGFloat {
        let total: CGFloat
        switch viewModel.phase {
        case .focus: total = CGFloat(viewModel.focusDuration)
        case .shortBreak: total = CGFloat(viewModel.shortBreakDuration)
        case .longBreak: total = CGFloat(viewModel.longBreakDuration)
        }
        return total > 0 ? CGFloat(viewModel.timeRemaining) / total : 0
    }

    private var phaseColor: Color {
        switch viewModel.phase {
        case .focus: return .blue
        case .shortBreak: return .green
        case .longBreak: return .purple
        }
    }

    @ViewBuilder
    private func pillButton(_ text: String, colors: [Color], action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.body.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(radius: 4)
        }
    }

    @ViewBuilder
    private func mainButton(title: String, colors: [Color], action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: colors.first?.opacity(0.4) ?? .black.opacity(0.3),
                        radius: 6, x: 0, y: 3)
        }
    }
}
