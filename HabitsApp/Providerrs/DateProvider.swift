import Foundation

protocol DateProvider {
    var now: Date { get }
    func startOfDay(for date: Date) -> Date
}

struct DefaultDateProvider: DateProvider {
    var now: Date { Date() }
    func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}
