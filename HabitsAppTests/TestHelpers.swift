import Foundation
@testable import HabitsApp

final class MockDateProvider: DateProvider {
    var current: Date
    init(now: Date) { self.current = now }
    var now: Date { current }
    func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}

final class InMemoryStore: KeyValueStore {
    private var storage: [String: Any] = [:]
    func string(forKey key: String) -> String? { storage[key] as? String }
    func integer(forKey key: String) -> Int { storage[key] as? Int ?? 0 }
    func dictionary(forKey key: String) -> [String : Any]? { storage[key] as? [String: Any] }
    func set(_ value: Any?, forKey key: String) { storage[key] = value }
}
