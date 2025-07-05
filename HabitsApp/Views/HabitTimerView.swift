import SwiftUI

struct HabitTimerView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @EnvironmentObject var timerState: TimerState
    @Environment(\.dismiss) private var dismiss

    let habit: Habit
    var completionDate: Date? = nil

    private var countdownFinished: Bool {
        timerState.isCountdown && timerState.elapsed >= timerState.duration && !timerState.isRunning
    }

    private var primaryButtonTitle: String {
        if timerState.isRunning {
            return "Stop"
        } else if timerState.elapsed > 0 && !countdownFinished {
            return "Continue"
        } else {
            return "Start"
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(habit.name)
                .font(.title)
                .padding(.top)

            Text(formattedTime)
                .font(.system(size: 48, weight: .bold, design: .monospaced))

            HStack(spacing: 40) {
                if timerState.isRunning || !countdownFinished {
                    Button(primaryButtonTitle) {
                        handlePrimaryAction()
                    }
                    .font(.title2)
                    .buttonStyle(TimerButtonStyle(background: timerState.isRunning ? .red : .green))
                }

                if !timerState.isRunning && timerState.elapsed > 0 {
                    Button("Save") { save() }
                        .font(.title2)
                        .buttonStyle(TimerButtonStyle(background: .blue))

                    Button("Save & Restart") { saveAndRestart() }
                        .font(.title2)
                        .buttonStyle(TimerButtonStyle(background: .orange))
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            timerState.currentHabit = habit
            timerState.completionDate = completionDate
            timerState.isMinimized = false
        }
        .onDisappear {
            if !timerState.isRunning && timerState.elapsed > 0 {
                recordCompletion()
            }
            timerState.isMinimized = timerState.isRunning
            timerState.showTimerView = false
        }
    }

    private var formattedTime: String {
        let time = timerState.isCountdown ? max(timerState.duration - timerState.elapsed, 0) : timerState.elapsed
        let totalSeconds = Int(time)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func stopTimer() {
        timerState.stop()
    }

    private func handlePrimaryAction() {
        if timerState.isRunning {
            stopTimer()
        } else if timerState.elapsed > 0 && !countdownFinished {
            timerState.resume()
        } else {
            if timerState.isCountdown {
                timerState.startCountdown(with: habit, completionDate: completionDate)
            } else {
                timerState.start(with: habit, completionDate: completionDate)
            }
        }
    }

    private func save() {
        stopTimer()
        recordCompletion()
        dismiss()
    }

    private func saveAndRestart() {
        stopTimer()
        recordCompletion(reset: false)
        if timerState.isCountdown {
            timerState.startCountdown(with: habit, completionDate: completionDate)
        } else {
            timerState.start(with: habit, completionDate: completionDate)
        }
    }

    private func recordCompletion(reset: Bool = true) {
        guard timerState.elapsed > 0 else { return }

        let minutes = Int(timerState.elapsed / 60)
        let baseValue = habit.value ?? 1
        var baseSeconds = Double(baseValue)
        if let unit = habit.unit?.lowercased(), unit.contains("hour") {
            baseSeconds *= 60
        }
        let multiplier = baseSeconds > 0 ? (timerState.elapsed / (baseSeconds * 60)) : 1
        let points = Int(round(Double(habit.points) * multiplier))

        let newHabit = Habit(id: UUID(),
                             name: habit.name,
                             points: points,
                             type: habit.type,
                             category: habit.category,
                             value: minutes,
                             unit: "minutes")

        if let day = completionDate {
            let now = Date()
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: day)
            let time = Calendar.current.dateComponents([.hour, .minute, .second], from: now)
            comps.hour = time.hour
            comps.minute = time.minute
            comps.second = time.second
            let timestamp = Calendar.current.date(from: comps) ?? day
            viewModel.addCompletion(newHabit, at: timestamp)
        } else {
            viewModel.addCompletion(newHabit, at: Date())
        }
        if reset {
            timerState.reset()
        }
    }
}

