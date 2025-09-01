import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: PomodoroViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Focus") {
                    durationStepper(
                        title: "Duration",
                        minutes: Binding(
                            get: { viewModel.focusDuration / 60 },
                            set: { viewModel.focusDuration = clampMinutes($0) * 60 }
                        )
                    )
                }

                Section("Short Break") {
                    durationStepper(
                        title: "Duration",
                        minutes: Binding(
                            get: { viewModel.shortBreakDuration / 60 },
                            set: { viewModel.shortBreakDuration = clampMinutes($0) * 60 }
                        )
                    )
                }

                Section("Long Break") {
                    durationStepper(
                        title: "Duration",
                        minutes: Binding(
                            get: { viewModel.longBreakDuration / 60 },
                            set: { viewModel.longBreakDuration = clampMinutes($0) * 60 }
                        )
                    )
                }

                Section(footer: Text("Tip: When the current phase is not running, changing its duration also resets the remaining time.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func clampMinutes(_ m: Int) -> Int {
        let minM = max(viewModel.minSeconds / 60, 1)   // 1
        let maxM = viewModel.maxSeconds / 60           // 180
        return min(max(m, minM), maxM)
    }

    @Environment(\.dismiss) private var dismiss

    @ViewBuilder
    private func durationStepper(title: String, minutes: Binding<Int>) -> some View {
        Stepper(value: minutes, in: 1...180) {
            HStack {
                Text(title)
                Spacer()
                Text("\(minutes.wrappedValue) min")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: PomodoroViewModel())
    }
}
