import SwiftUI

@main
struct HabitsAppApp: App {
    @StateObject private var viewModel: HabitViewModel

    init() {
        let initialHabits = [
            Habit(name: "Drink Water", points: 2,  type: .good, category: "Health"),
            Habit(name: "Meditate",    points:10, type: .good, category: "Mindfulness"),
            Habit(name: "Workout",     points:15, type: .good, category: "Fitness"),
            Habit(name: "Junk Food",   points:-10,type: .bad,  category: "Diet"),
            Habit(name: "Procrastinate", points:-5, type: .bad, category: "Productivity")
        ]
        let repository = FileHabitRepository(initialHabits: initialHabits)
        let service    = HabitService(repository: repository)
        _viewModel     = StateObject(wrappedValue: HabitViewModel(service: service))
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)
                .fullScreenCover(isPresented: Binding(
                    get: { !viewModel.isRegistered },
                    set: { _ in }
                )) {
                    RegistrationView()
                        .environmentObject(viewModel)
                }
        }
    }
}
