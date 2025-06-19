import Foundation

private struct HabitCompletion: Codable {
    let habit: Habit
    let date: Date
}

class FileHabitRepository: HabitRepository {
    private let fileURL: URL
    private let initialHabits: [Habit]
    private var completed: [Habit: Date] = [:]

    init(initialHabits: [Habit], filename: String = "habit_completions.json") {
        self.initialHabits = initialHabits
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = docs.appendingPathComponent(filename)
        load()
    }

    func fetchAllHabits() -> [Habit] { initialHabits }
    func fetchCompletedHabits() -> [Habit: Date] { completed }
    func saveCompletion(_ habit: Habit, at date: Date) {
        completed[habit] = date
        save()
    }
    func deleteCompletion(_ habit: Habit) {
        completed.removeValue(forKey: habit)
        save()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            let list = try JSONDecoder().decode([HabitCompletion].self, from: data)
            completed = Dictionary(uniqueKeysWithValues: list.map { ($0.habit, $0.date) })
        } catch {
            print("[FileHabitRepository] Load error: \(error)")
        }
    }

    private func save() {
        let list = completed.map { HabitCompletion(habit: $0.key, date: $0.value) }
        do {
            let data = try JSONEncoder().encode(list)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("[FileHabitRepository] Save error: \(error)")
        }
    }
}
