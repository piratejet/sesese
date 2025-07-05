import SwiftUI

@main
struct HabitsAppApp: App {
    @StateObject private var viewModel: HabitViewModel
    @StateObject private var timerState = TimerState()

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
                .environmentObject(timerState)
                .overlay(alignment: .bottomTrailing) {
                    if timerState.isMinimized && timerState.isRunning {
                        FloatingTimerView()
                            .environmentObject(timerState)
                            .padding()
                    }
                }
                .sheet(isPresented: $timerState.showTimerView) {
                    if let habit = timerState.currentHabit {
                        HabitTimerView(habit: habit, completionDate: timerState.completionDate)
                            .environmentObject(viewModel)
                            .environmentObject(timerState)
                    }
                }
                .fullScreenCover(isPresented: Binding(
                    get: { !viewModel.isRegistered },
                    set: { _ in }
                )) {
                    RegistrationView()
                        .environmentObject(viewModel)
                        .environmentObject(timerState)
                }
        }
    }
}
