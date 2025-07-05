import Foundation
import Combine

class TimerState: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var elapsed: TimeInterval = 0
    private var startTime: Date?
    private var timer: Timer?
    private let timerInterval: TimeInterval = 1

    func start() {
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
