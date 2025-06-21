import SwiftUI

struct HabitTemplatesView: View {
    @EnvironmentObject private var viewModel: HabitViewModel
    @State private var showAdd = false
    @State private var editingHabit: Habit?

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.allHabits) { habit in
                    HStack {
                        Text(habit.name)
                        Spacer()
                        Text("\(habit.points)")
                            .foregroundColor(habit.points >= 0 ? .green : .red)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { editingHabit = habit }
                }
                .onDelete { indexSet in
                    indexSet.forEach { idx in
                        let habit = viewModel.allHabits[idx]
                        viewModel.removeHabitTemplate(habit)
                    }
                }
            }
            .navigationTitle("Habit Templates")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $editingHabit) { habit in
                let cats = Set(viewModel.categories.filter { $0 != "All" } + [habit.category]).sorted()
                HabitTemplateFormView(habit: habit, categories: cats, reminder: viewModel.reminderTime(for: habit)) { updated, comps in
                    viewModel.updateHabitTemplate(updated)
                    if let c = comps, let date = Calendar.current.date(from: c) {
                        viewModel.scheduleReminder(for: updated, time: date)
                    } else {
                        viewModel.removeReminder(for: updated)
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                let cats = viewModel.categories.filter { $0 != "All" }
                HabitTemplateFormView(habit: nil, categories: cats, reminder: nil) { newHabit, comps in
                    viewModel.addHabitTemplate(newHabit)
                    if let c = comps, let date = Calendar.current.date(from: c) {
                        viewModel.scheduleReminder(for: newHabit, time: date)
                    }
                }
            }
        }
    }
}
