import Foundation
import Combine

class TimerState: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var elapsed: TimeInterval = 0
    @Published var currentHabit: Habit?
    @Published var completionDate: Date?
    @Published var isMinimized: Bool = false
    @Published var showTimerView: Bool = false

    private var startTime: Date?
    private var timer: Timer?
    private let timerInterval: TimeInterval = 1

    func start(with habit: Habit? = nil, completionDate: Date? = nil) {
        if let habit = habit {
            self.currentHabit = habit
        }
        if let date = completionDate {
            self.completionDate = date
        }
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
            }
        }
    }
}
