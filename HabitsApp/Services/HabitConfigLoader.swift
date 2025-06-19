import Foundation

struct HabitConfigLoader {

    /// Fallback habits used when a configuration file cannot be loaded.
    private static let builtInHabits: [Habit] = [
        Habit(name: "Drink Water",    points: 2,  type: .good, category: "Health",       value: 1,  unit: "cup"),
        Habit(name: "Meditate",       points: 10, type: .good, category: "Mindfulness", value: 15, unit: "minutes"),
        Habit(name: "Workout",        points: 15, type: .good, category: "Fitness",     value: 30, unit: "minutes"),
        Habit(name: "Read Book",      points: 5,  type: .good, category: "Mindfulness", value: 20, unit: "pages"),
        Habit(name: "Walk",           points: 5,  type: .good, category: "Fitness",     value: 1,  unit: "mile"),
        Habit(name: "Junk Food",      points: -10, type: .bad, category: "Diet"),
        Habit(name: "Procrastinate", points: -5,  type: .bad, category: "Productivity"),
        Habit(name: "Smoke",          points: -15, type: .bad, category: "Health")
    ]

    static func load(from fileName: String = "initial_habits.json") -> [Habit] {
        // Try to load the config file from the application bundle first.
        if let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
            do {
                let data = try Data(contentsOf: url)
                let habits = try JSONDecoder().decode([Habit].self, from: data)
                return habits
            } catch {
                print("[HabitConfigLoader] Failed to decode \(fileName): \(error)")
            }
        } else {
            print("[HabitConfigLoader] Could not find \(fileName) in bundle")
        }

        // Fallback to the built‑in defaults so the UI isn't empty.
        return builtInHabits
    }
}
