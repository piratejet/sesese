// File: Views/HabitSelectionView.swift
import SwiftUI

struct HabitSelectionView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @Binding var selectedCategory: String
    @Binding var selectedType: HabitType?
    var completionDate: Date?      // Optional day you tapped
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

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

    var body: some View {
        NavigationStack {
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
                        Button {
                            // Use the correct ViewModel methods
                            if let day = completionDate {
                                // Preserve the selected day but use the current time
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
                        } label: {
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
                                Text("\(habit.points > 0 ? "+" : "")\(habit.points) pts")
                                    .bold()
                                    .foregroundColor(habit.points > 0 ? .green : .red)
                            }
                        }
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
        }
    }
}
