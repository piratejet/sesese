import Foundation

protocol HabitRepository {
    func fetchAllHabits() -> [Habit]
    func fetchCompletedHabits() -> [Habit: Date]
    func saveCompletion(_ habit: Habit, at date: Date)
    func deleteCompletion(_ habit: Habit)

    // Template management
    func addHabitTemplate(_ habit: Habit)
    func updateHabitTemplate(_ habit: Habit)
    func removeHabitTemplate(_ habit: Habit)
}
