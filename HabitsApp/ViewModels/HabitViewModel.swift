// File: ViewModels/HabitViewModel.swift
import Foundation
import Combine

/// Protocol to abstract key–value storage for user info
protocol KeyValueStore {
    func string(forKey key: String) -> String?
    func integer(forKey key: String) -> Int
    func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: KeyValueStore {
    func integer(forKey key: String) -> Int {
        object(forKey: key) as? Int ?? 0
    }
}

/// A user achievement/trophy
struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    var unlockedDate: Date? = nil
    let criteria: (HabitViewModel) -> Bool
}

class HabitViewModel: ObservableObject {
    // MARK: - Published State
    @Published var totalPoints: Int = 0
    @Published var gems: Int = 0
    @Published var dailyProgress: Double = 0.0
    @Published var categories: [String] = []
    @Published var dailyHistory: [(date: Date, habits: [Habit])] = []
    @Published var allHabits: [Habit] = []
    @Published var lastDeletion: (habit: Habit, date: Date)?

    @Published var userName: String
    @Published var userEmail: String
    @Published var achievements: [Achievement] = []

    // MARK: - Dependencies
    let service: HabitService
    private let store: KeyValueStore
    private var milestoneLevel: Int
    private let milestoneInterval: Int = 100

    /// Indicates whether the user has completed registration
    var isRegistered: Bool { !userName.isEmpty && !userEmail.isEmpty }

    // MARK: - Initialization
    init(service: HabitService, store: KeyValueStore = UserDefaults.standard) {
        self.service = service
        self.store   = store
        self.userName  = store.string(forKey: "userName")  ?? ""
        self.userEmail = store.string(forKey: "userEmail") ?? ""
        self.gems      = store.integer(forKey: "gems")
        self.milestoneLevel = store.integer(forKey: "milestoneLevel")
        setupAchievements()
        reloadAll()
    }

    // MARK: - Data Loading
    func reloadAll() {
        totalPoints   = service.totalPointsAllTime()
        dailyProgress = service.dailyProgress()
        categories    = service.categories()
        dailyHistory  = service.dailyHistory()
        allHabits     = service.fetchAllHabits()
        evaluateAchievements()
        evaluateMilestones()
    }

    // MARK: - Habit Completion
    func add(_ habit: Habit) {
        addCompletion(habit, at: Date())
    }

    func addCompletion(_ habit: Habit, at date: Date) {
        service.addCompletion(habit, at: date)
        reloadAll()
    }

    // MARK: - Removal & Undo
    func remove(_ habit: Habit) {
        if let date = service.fetchCompletedHabitDates()[habit] {
            lastDeletion = (habit, date)
        }
        service.removeCompletion(habit)
        reloadAll()
    }

    func undoLastDeletion() {
        guard let deletion = lastDeletion else { return }
        service.addCompletion(deletion.habit, at: deletion.date)
        lastDeletion = nil
        reloadAll()
    }

    // MARK: - Habit Template Management
    func addHabitTemplate(_ habit: Habit) {
        service.addHabitTemplate(habit)
        reloadAll()
    }

    func updateHabitTemplate(_ habit: Habit) {
        service.updateHabitTemplate(habit)
        reloadAll()
    }

    func removeHabitTemplate(_ habit: Habit) {
        service.removeHabitTemplate(habit)
        reloadAll()
    }

    /// Retrieve the completion date for a given habit, if available
    func completionDate(for habit: Habit) -> Date? {
        service.fetchCompletedHabitDates()[habit]
    }

    // MARK: - User Registration
    func register(name: String, email: String) {
        userName  = name
        userEmail = email
        store.set(name,  forKey: "userName")
        store.set(email, forKey: "userEmail")
    }

    // MARK: - Achievements Setup & Evaluation
    private func setupAchievements() {
        achievements = [
            Achievement(
                id: "streak80",
                title: "80% Daily Streak",
                description: "Achieve at least 80% daily progress for 7 days",
                criteria: { vm in vm.hasProgressStreak(days: 7, threshold: 0.8) }
            ),
            Achievement(
                id: "water7",
                title: "7-Day Water Streak",
                description: "Drink water every day for a week",
                criteria: { vm in vm.hasHabitStreak(habitName: "Drink Water", days: 7) }
            )
        ]
    }

    private func evaluateAchievements() {
        for index in achievements.indices {
            if achievements[index].unlockedDate == nil,
               achievements[index].criteria(self) {
                achievements[index].unlockedDate = Date()
                addGems(1)
            }
        }
    }

    private func evaluateMilestones() {
        let currentLevel = totalPoints / milestoneInterval
        if currentLevel > milestoneLevel {
            let diff = currentLevel - milestoneLevel
            milestoneLevel = currentLevel
            store.set(milestoneLevel, forKey: "milestoneLevel")
            addGems(diff)
        }
    }

    private func addGems(_ amount: Int) {
        gems += amount
        store.set(gems, forKey: "gems")
    }

    // MARK: - Achievement Criteria Helpers
    private var dailyProgressHistory: [(date: Date, progress: Double)] {
        let target = 100.0
        return dailyHistory.map { entry in
            let total = entry.habits.reduce(0) { acc, h in acc + h.points }
            let frac  = min(Double(total) / target, 1.0)
            return (date: Calendar.current.startOfDay(for: entry.date), progress: frac)
        }
        .sorted { $0.date > $1.date }
    }

    func hasProgressStreak(days: Int, threshold: Double) -> Bool {
        let history = dailyProgressHistory
        var count = 0
        var expected = Calendar.current.startOfDay(for: Date())
        for entry in history {
            if Calendar.current.isDate(entry.date, inSameDayAs: expected) {
                if entry.progress >= threshold {
                    count += 1
                    if count >= days { return true }
                    expected = Calendar.current.date(byAdding: .day, value: -1, to: expected)!
                } else { break }
            }
        }
        return false
    }

    func hasHabitStreak(habitName: String, days: Int) -> Bool {
        let history = dailyHistory
            .map { (date: Calendar.current.startOfDay(for: $0.date), habits: $0.habits) }
            .sorted { $0.date > $1.date }
        var count = 0
        var expected = Calendar.current.startOfDay(for: Date())
        for entry in history {
            if Calendar.current.isDate(entry.date, inSameDayAs: expected) {
                if entry.habits.contains(where: { $0.name == habitName }) {
                    count += 1
                    if count >= days { return true }
                    expected = Calendar.current.date(byAdding: .day, value: -1, to: expected)!
                } else { break }
            }
        }
        return false
    }
}

// MARK: - Insights Extension
extension HabitViewModel {
    var pointsLast30Days: [(date: Date, points: Int)] {
        let today = Calendar.current.startOfDay(for: Date())
        return (0..<30).compactMap { offset in
            guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: today)
            else { return nil }
            let points = dailyHistory
                .first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })?
                .habits.reduce(0) { acc, h in acc + h.points } ?? 0
            return (date: date, points: points)
        }
        .reversed()
    }

    var rolling7DayAverage: [(date: Date, average: Double)] {
        let history = pointsLast30Days
        return history.indices.compactMap { idx in
            guard idx >= 6 else { return nil }
            let window = history[(idx-6)...idx]
            let avg = Double(window.map { $0.points }.reduce(0, +)) / Double(window.count)
            return (date: history[idx].date, average: avg)
        }
    }

    var monthlyTotals: [(month: Date, points: Int)] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<6).compactMap { offset in
            guard let monthDate = calendar.date(byAdding: .month, value: -offset, to: now)
            else { return nil }
            let comps = calendar.dateComponents([.year, .month], from: monthDate)
            let total = dailyHistory
                .filter { calendar.dateComponents([.year, .month], from: $0.date) == comps }
                .flatMap { $0.habits }
                .reduce(0) { acc, h in acc + h.points }
            guard let firstOfMonth = calendar.date(from: comps) else { return nil }
            return (month: firstOfMonth, points: total)
        }
        .reversed()
    }

    var bestDay: (date: Date, points: Int)? {
        dailyHistory
            .map { (date: $0.date, points: $0.habits.reduce(0) { acc, h in acc + h.points }) }
            .max(by: { $0.points < $1.points })
    }

    var worstDay: (date: Date, points: Int)? {
        dailyHistory
            .map { (date: $0.date, points: $0.habits.reduce(0) { acc, h in acc + h.points }) }
            .min(by: { $0.points < $1.points })
    }

    var averagePointsPerDay: Double {
        let totals = dailyHistory
            .map { $0.habits.reduce(0) { acc, h in acc + h.points } }
        guard !totals.isEmpty else { return 0 }
        return Double(totals.reduce(0, +)) / Double(totals.count)
    }

    var currentStreak: Int {
        let sortedDates = dailyHistory
            .map { Calendar.current.startOfDay(for: $0.date) }
            .sorted(by: >)
        var streak = 0
        var expected = Calendar.current.startOfDay(for: Date())
        for date in sortedDates {
            if Calendar.current.isDate(date, inSameDayAs: expected) {
                streak += 1
                expected = Calendar.current.date(byAdding: .day, value: -1, to: expected)!
            } else { break }
        }
        return streak
    }

    var weeklyCompletionCounts: [(weekStart: Date, count: Int)] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<8).compactMap { offset in
            guard let wk = calendar.date(byAdding: .weekOfYear, value: -offset, to: now)
            else { return nil }
            let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: wk)
            guard let weekStart = calendar.date(from: comps) else { return nil }
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            let count = dailyHistory
                .filter { $0.date >= weekStart && $0.date <= weekEnd }
                .flatMap { $0.habits }
                .count
            return (weekStart: weekStart, count: count)
        }
        .reversed()
    }
}
