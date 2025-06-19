import SwiftUI

@main
struct HabitsAppApp: App {
    @StateObject private var viewModel: HabitViewModel

    init() {
        let initialHabits = HabitConfigLoader.load()
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
