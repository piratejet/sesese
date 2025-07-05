// File: Views/HabitSelectionView.swift
import SwiftUI

struct HabitSelectionView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @EnvironmentObject var timerState: TimerState
    @Binding var selectedCategory: String
    @Binding var selectedType: HabitType?
    var completionDate: Date?      // Optional day you tapped
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var pendingHabit: Habit?
    @State private var showConfirm = false

    // Simple filter in one computed property
    private var filteredHabits: [Habit] {
        viewModel.allHabits.filter { habit in
            let matchesCategory = (selectedCategory == "All") || (habit.category == selectedCategory)
            let matchesType     = (selectedType == nil)       || (habit.type == selectedType)
            let matchesSearch   = searchText.isEmpty           ||
                                  habit.name.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesType && matchesSearch
        }
    }

    private func isTimeBased(_ habit: Habit) -> Bool {
        guard let unit = habit.unit?.lowercased() else { return false }
        return unit.contains("minute") || unit.contains("hour")
    }

    private func addHabit(_ habit: Habit) {
        if let day = completionDate {
            let now = Date()
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: day)
            let time = Calendar.current.dateComponents([.hour, .minute, .second], from: now)
            comps.hour = time.hour
            comps.minute = time.minute
            comps.second = time.second
            let timestamp = Calendar.current.date(from: comps) ?? day
            viewModel.addCompletion(habit, at: timestamp)
        } else {
            viewModel.add(habit)
        }
        dismiss()
    }

    var body: some View {
        NavigationStack {
            habitList
        }
    }

    @ViewBuilder
    private var habitList: some View {
        List {
            Section("Filters") {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Text(category)
                    }
                }
                Picker("Habit Type", selection: $selectedType) {
                    Text("All").tag(nil as HabitType?)
                    ForEach(HabitType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type as HabitType?)
                    }
                }
            }

            Section("Habits") {
                ForEach(filteredHabits) { habit in
                    habitButton(for: habit)
                }
            }
        }
        .navigationTitle("Add Habit")
        .searchable(text: $searchText, prompt: "Search habits")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .confirmationDialog(
            "Add Habit",
            isPresented: $showConfirm,
            titleVisibility: .visible,
            presenting: pendingHabit
        ) { habit in
            Button("Add Now") {
                addHabit(habit)
                pendingHabit = nil
            }
            if isTimeBased(habit) {
                Button("Start Timer") {
                    timerState.start(with: habit, completionDate: completionDate)
                    timerState.isMinimized = false
                    timerState.showTimerView = true
                    pendingHabit = nil
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { habit in
            Text("How do you want to log \(habit.name)?")
        }
    }

    @ViewBuilder
    private func habitButton(for habit: Habit) -> some View {
        Button {
            if isTimeBased(habit) {
                pendingHabit = habit
                showConfirm = true
            } else {
                addHabit(habit)
            }
        } label: {
            habitRow(for: habit)
        }
        .contextMenu {
            if isTimeBased(habit) {
                Button("Start Timer") {
                    timerState.start(with: habit, completionDate: completionDate)
                    timerState.isMinimized = false
                    timerState.showTimerView = true
                }
            }
        }
    }

    @ViewBuilder
    private func habitRow(for habit: Habit) -> some View {
        HStack {
            Image(systemName: habit.type == .good
                  ? "plus.circle.fill" : "minus.circle.fill")
                .foregroundColor(habit.type == .good ? .green : .red)
            if let value = habit.value, let unit = habit.unit {
                Text("\(habit.name) (\(value) \(unit))")
            } else {
                Text(habit.name)
            }
            Spacer()
            Text(pointsLabel(for: habit))
                .bold()
                .foregroundColor(habit.points > 0 ? .green : .red)
        }
    }

    private func pointsLabel(for habit: Habit) -> String {
        let prefix = habit.points > 0 ? "+" : ""
        return "\(prefix)\(habit.points) pts"
    }
}
