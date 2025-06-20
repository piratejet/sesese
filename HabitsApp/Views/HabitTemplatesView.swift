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
                HabitTemplateFormView(habit: habit, categories: cats) { updated in
                    viewModel.updateHabitTemplate(updated)
                }
            }
            .sheet(isPresented: $showAdd) {
                let cats = viewModel.categories.filter { $0 != "All" }
                HabitTemplateFormView(habit: nil, categories: cats) { newHabit in
                    viewModel.addHabitTemplate(newHabit)
                }
            }
        }
    }
}
