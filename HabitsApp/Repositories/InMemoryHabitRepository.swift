import Foundation

class InMemoryHabitRepository: HabitRepository {
    private(set) var habits: [Habit]
    private(set) var completed: [Habit: Date]

    init(initialHabits: [Habit] = []) {
        self.habits = initialHabits
        self.completed = [:]
    }

    func fetchAllHabits() -> [Habit] { habits }
    func fetchCompletedHabits() -> [Habit: Date] { completed }
    func saveCompletion(_ habit: Habit, at date: Date) { completed[habit] = date }
    func deleteCompletion(_ habit: Habit) { completed.removeValue(forKey: habit) }

    // MARK: - Template Management
    func addHabitTemplate(_ habit: Habit) {
        habits.append(habit)
    }

    func updateHabitTemplate(_ habit: Habit) {
        if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[idx] = habit
        }
    }

    func removeHabitTemplate(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        completed.removeValue(forKey: habit)
    }
}
