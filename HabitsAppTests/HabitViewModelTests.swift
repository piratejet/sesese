import Foundation
import Testing
@testable import HabitsApp

struct HabitViewModelTests {
    @Test func addAndRemoveHabit() async throws {
        let habit = Habit(name: "Water", points: 10, type: .good, category: "Health")
        let repo = InMemoryHabitRepository(initialHabits: [habit])
        let provider = MockDateProvider(now: Date())
        let service = HabitService(repository: repo, clock: provider)
        let vm = HabitViewModel(service: service, store: InMemoryStore())

        vm.add(habit)
        #expect(vm.totalPoints == 10)
        #expect(vm.dailyProgress == 0.1)

        vm.remove(habit)
        #expect(vm.totalPoints == 0)
        #expect(vm.dailyProgress == 0)
    }

    @Test func unlockStreakAchievement() async throws {
        let habit = Habit(name: "Big", points: 100, type: .good, category: "Gen")
        let repo = InMemoryHabitRepository(initialHabits: [habit])
        let start = Date(timeIntervalSince1970: 0)
        let provider = MockDateProvider(now: start)
        let service = HabitService(repository: repo, clock: provider)
        let vm = HabitViewModel(service: service, store: InMemoryStore())

        for day in 0..<7 {
            provider.current = start.addingTimeInterval(Double(day) * 86_400)
            vm.addCompletion(habit, at: provider.current)
        }

        let ach = vm.achievements.first { $0.id == "streak80" }
        #expect(ach?.unlockedDate != nil)
    }

    @Test func unlockWaterAchievement() async throws {
        let habit = Habit(name: "Drink Water", points: 2, type: .good, category: "Health")
        let repo = InMemoryHabitRepository(initialHabits: [habit])
        let start = Date(timeIntervalSince1970: 0)
        let provider = MockDateProvider(now: start)
        let service = HabitService(repository: repo, clock: provider)
        let vm = HabitViewModel(service: service, store: InMemoryStore())

        for day in 0..<7 {
            provider.current = start.addingTimeInterval(Double(day) * 86_400)
            vm.addCompletion(habit, at: provider.current)
        }

        let ach = vm.achievements.first { $0.id == "water7" }
        #expect(ach?.unlockedDate != nil)
    }
}
