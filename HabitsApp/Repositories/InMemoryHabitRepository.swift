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
}
