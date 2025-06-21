import Foundation
import Testing
@testable import HabitsApp

struct HabitServiceTests {
    @Test func addAndRemoveCompletion() async throws {
        let repo = InMemoryHabitRepository()
        let provider = MockDateProvider(now: Date())
        let service = HabitService(repository: repo, clock: provider)

        let habit = Habit(name: "Test", points: 10, type: .good, category: "Gen")
        service.addCompletion(habit)
        #expect(repo.fetchCompletedHabits()[habit] != nil)
        #expect(service.totalPointsToday() == 10)
        #expect(service.dailyProgress() == 0.1)

        service.removeCompletion(habit)
        #expect(repo.fetchCompletedHabits()[habit] == nil)
        #expect(service.totalPointsToday() == 0)
        #expect(service.dailyProgress() == 0)
    }

    @Test func progressAcrossDays() async throws {
        let repo = InMemoryHabitRepository()
        let start = Date(timeIntervalSince1970: 0)
        let provider = MockDateProvider(now: start)
        let service = HabitService(repository: repo, clock: provider)
        let habit = Habit(name: "Test", points: 50, type: .good, category: "Gen")

        service.addCompletion(habit, at: start)
        #expect(service.totalPointsToday() == 50)

        provider.current = start.addingTimeInterval(86_400)
        service.addCompletion(habit, at: provider.current)
        #expect(service.totalPointsToday() == 50)
        #expect(service.dailyProgress() == 0.5)
    }
}
