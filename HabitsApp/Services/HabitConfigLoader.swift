import Foundation

struct HabitConfigLoader {
    static func load(from fileName: String = "initial_habits.json") -> [Habit] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("[HabitConfigLoader] Could not find \(fileName) in bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let habits = try JSONDecoder().decode([Habit].self, from: data)
            return habits
        } catch {
            print("[HabitConfigLoader] Failed to load habits: \(error)")
            return []
        }
    }
}
