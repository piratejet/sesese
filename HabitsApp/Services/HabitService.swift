import Foundation

class HabitService {
    private let repository: HabitRepository
    private let clock: DateProvider
    private let dailyTarget: Double = 100

    init(repository: HabitRepository, clock: DateProvider = DefaultDateProvider()) {
        self.repository = repository
        self.clock = clock
    }

    /// Record completion at the current time
    func addCompletion(_ habit: Habit) {
        repository.saveCompletion(habit, at: clock.now)
    }

    /// Record completion at a specific date (for undo)
    func addCompletion(_ habit: Habit, at date: Date) {
        repository.saveCompletion(habit, at: date)
    }

    /// Remove a completion
    func removeCompletion(_ habit: Habit) {
        repository.deleteCompletion(habit)
    }

    /// Expose raw completed-habit dates for undo
    func fetchCompletedHabitDates() -> [Habit: Date] {
        repository.fetchCompletedHabits()
    }

    /// Total points accumulated today
    func totalPointsToday() -> Int {
        let start = clock.startOfDay(for: clock.now)
        return repository.fetchCompletedHabits()
            .filter { $0.value >= start }
            .reduce(0) { $0 + $1.key.points }
    }

    /// Total points accumulated across all time
    func totalPointsAllTime() -> Int {
        repository.fetchCompletedHabits()
            .reduce(0) { $0 + $1.key.points }
    }

    /// Fractional progress toward daily target
    func dailyProgress() -> Double {
        min(Double(totalPointsToday()) / dailyTarget, 1.0)
    }

    /// Group completions by day, newest first
    func dailyHistory() -> [(date: Date, habits: [Habit])] {
        let groups = Dictionary(grouping: repository.fetchCompletedHabits()) { pair in
            clock.startOfDay(for: pair.value)
        }
        return groups
            .map { (date: $0.key, habits: $0.value.map { $0.key }) }
            .sorted { $0.date > $1.date }
    }

    /// All distinct categories (for filtering)
    func categories() -> [String] {
        let set = Set(repository.fetchAllHabits().map { $0.category })
        return ["All"] + set.sorted()
    }

    /// Return the full list of habit templates
    func fetchAllHabits() -> [Habit] {
        repository.fetchAllHabits()
    }
}
