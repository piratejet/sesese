import Foundation
import Combine
import AudioToolbox

class TimerState: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var elapsed: TimeInterval = 0
    @Published var isCountdown: Bool = false
    @Published var duration: TimeInterval = 0
    @Published var currentHabit: Habit?
    @Published var completionDate: Date?
    @Published var isMinimized: Bool = false
    @Published var showTimerView: Bool = false

    private var startTime: Date?
    private var timer: Timer?
    private let timerInterval: TimeInterval = 1

    private func playAlarm() {
        // Use a built-in system sound for the alarm
        AudioServicesPlaySystemSound(SystemSoundID(1013))
    }

    func start(with habit: Habit? = nil, completionDate: Date? = nil) {
        if let habit = habit {
            self.currentHabit = habit
        }
        if let date = completionDate {
            self.completionDate = date
        }
        isCountdown = false
        duration = 0
        startTime = Date()
        elapsed = 0
        isRunning = true
        scheduleTimer()
    }

    /// Resume the timer using the current elapsed value without resetting
    func resume() {
        guard !isRunning else { return }
        // Continue from the previously elapsed time
        startTime = Date().addingTimeInterval(-elapsed)
        isRunning = true
        scheduleTimer()
    }

    func startCountdown(with habit: Habit, completionDate: Date? = nil) {
        currentHabit = habit
        completionDate.map { self.completionDate = $0 }
        duration = Self.seconds(for: habit)
        isCountdown = true
        startTime = Date()
        elapsed = 0
        isRunning = true
        scheduleTimer()
    }

    func stop() {
        isRunning = false
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        startTime = nil
        elapsed = 0
        duration = 0
        isCountdown = false
        isRunning = false
        isMinimized = false
        showTimerView = false
        currentHabit = nil
        completionDate = nil
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let start = self.startTime, self.isRunning {
                self.elapsed = Date().timeIntervalSince(start)
                if self.isCountdown && self.elapsed >= self.duration {
                    self.elapsed = self.duration
                    self.isRunning = false
                    self.timer?.invalidate()
                    self.playAlarm()
                }
            }
        }
    }

    private static func seconds(for habit: Habit) -> TimeInterval {
        guard let value = habit.value else { return 0 }
        var seconds = Double(value)
        if let unit = habit.unit?.lowercased() {
            if unit.contains("hour") { seconds *= 3600 }
            else if unit.contains("minute") { seconds *= 60 }
        }
        return seconds
    }
}
