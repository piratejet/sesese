import Foundation

private struct HabitCompletion: Codable {
    let habit: Habit
    let date: Date
}

class FileHabitRepository: HabitRepository {
    private let completionsURL: URL
    private let templatesURL: URL
    private var habits: [Habit]
    private var completed: [Habit: Date] = [:]

    init(initialHabits: [Habit],
         completionsFilename: String = "habit_completions.json",
         templatesFilename: String = "habit_templates.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.completionsURL = docs.appendingPathComponent(completionsFilename)
        self.templatesURL = docs.appendingPathComponent(templatesFilename)
        self.habits = initialHabits
        load()
    }

    func fetchAllHabits() -> [Habit] { habits }
    func fetchCompletedHabits() -> [Habit: Date] { completed }
    func saveCompletion(_ habit: Habit, at date: Date) {
        completed[habit] = date
        saveCompletions()
    }
    func deleteCompletion(_ habit: Habit) {
        completed.removeValue(forKey: habit)
        saveCompletions()
    }

    // MARK: - Template Management
    func addHabitTemplate(_ habit: Habit) {
        habits.append(habit)
        saveTemplates()
    }

    func updateHabitTemplate(_ habit: Habit) {
        if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[idx] = habit
            saveTemplates()
        }
    }

    func removeHabitTemplate(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        completed.removeValue(forKey: habit)
        saveTemplates()
        saveCompletions()
    }

    private func load() {
        loadCompletions()
        loadTemplates()
    }

    private func loadCompletions() {
        guard FileManager.default.fileExists(atPath: completionsURL.path) else { return }
        do {
            let data = try Data(contentsOf: completionsURL)
            let list = try JSONDecoder().decode([HabitCompletion].self, from: data)
            completed = Dictionary(uniqueKeysWithValues: list.map { ($0.habit, $0.date) })
        } catch {
            print("[FileHabitRepository] Load completions error: \(error)")
        }
    }

    private func saveCompletions() {
        let list = completed.map { HabitCompletion(habit: $0.key, date: $0.value) }
        do {
            let data = try JSONEncoder().encode(list)
            try data.write(to: completionsURL, options: .atomic)
        } catch {
            print("[FileHabitRepository] Save completions error: \(error)")
        }
    }

    private func loadTemplates() {
        guard FileManager.default.fileExists(atPath: templatesURL.path) else { return }
        do {
            let data = try Data(contentsOf: templatesURL)
            habits = try JSONDecoder().decode([Habit].self, from: data)
        } catch {
            print("[FileHabitRepository] Load templates error: \(error)")
        }
    }

    private func saveTemplates() {
        do {
            let data = try JSONEncoder().encode(habits)
            try data.write(to: templatesURL, options: .atomic)
        } catch {
            print("[FileHabitRepository] Save templates error: \(error)")
        }
    }
}
