import Foundation

enum HabitType: String, CaseIterable, Codable {
    case good = "Good Habit"
    case bad = "Bad Habit"
}

struct Habit: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let points: Int
    let type: HabitType
    let category: String

    init(id: UUID = UUID(), name: String, points: Int, type: HabitType, category: String) {
        self.id = id
        self.name = name
        self.points = points
        self.type = type
        self.category = category
    }
}
