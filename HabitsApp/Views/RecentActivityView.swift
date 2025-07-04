import SwiftUI

struct RecentActivityView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @State private var showingDeleteAlert = false
    @State private var habitToDelete: Habit?

    var sortedActivities: [(habit: Habit, date: Date)] {
        viewModel.dailyHistory.flatMap { entry in
            entry.habits.compactMap { habit in
                guard let actual = viewModel.completionDate(for: habit) else { return nil }
                return (habit: habit, date: actual)
            }
        }.sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Activity").font(.headline).padding(.horizontal)
            if sortedActivities.isEmpty {
                Text("No activities yet").foregroundColor(.gray).padding()
            } else {
                ForEach(sortedActivities.prefix(3), id: \.habit.id) { activity in
                    ActivityRow(habit: activity.habit, date: activity.date) {
                        habitToDelete = activity.habit
                        showingDeleteAlert = true
                    }
                }
            }
        }
        .alert("Remove Activity", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                if let habit = habitToDelete {
                    viewModel.remove(habit)
                }
            }
        } message: {
            Text("Are you sure you want to remove this activity?")
        }
    }
}
