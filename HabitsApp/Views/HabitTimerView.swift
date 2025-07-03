import SwiftUI

struct HabitTimerView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @Environment(\.dismiss) private var dismiss

    let habit: Habit
    var completionDate: Date? = nil

    @State private var isRunning = false
    @State private var startTime: Date?
    @State private var elapsed: TimeInterval = 0
    private let timerInterval: TimeInterval = 1

    var body: some View {
        VStack(spacing: 20) {
            Text(habit.name)
                .font(.title)
                .padding(.top)

            Text(formattedTime)
                .font(.system(size: 48, weight: .bold, design: .monospaced))

            HStack(spacing: 40) {
                Button(isRunning ? "Stop" : "Start") {
                    isRunning ? stopTimer() : startTimer()
                }
                .font(.title2)
                .padding()
                .background(isRunning ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                .cornerRadius(8)

                if !isRunning && elapsed > 0 {
                    Button("Save") {
                        save()
                    }
                    .font(.title2)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            Spacer()
        }
        .padding()
        .onDisappear { stopTimer() }
    }

    private var formattedTime: String {
        let totalSeconds = Int(elapsed)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func startTimer() {
        startTime = Date()
        isRunning = true
        elapsed = 0
        Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { timer in
            if let start = startTime, isRunning {
                elapsed = Date().timeIntervalSince(start)
            } else {
                timer.invalidate()
            }
        }
    }

    private func stopTimer() {
        isRunning = false
    }

    private func save() {
        stopTimer()
        guard elapsed > 0 else { return }

        let minutes = Int(elapsed / 60)
        let baseValue = habit.value ?? 1
        var baseSeconds = Double(baseValue)
        if let unit = habit.unit?.lowercased(), unit.contains("hour") {
            baseSeconds *= 60
        }
        let multiplier = baseSeconds > 0 ? (elapsed / (baseSeconds * 60)) : 1
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
        dismiss()
    }
}

