import SwiftUI

struct HabitTemplateFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var points: Int
    @State private var type: HabitType
    @State private var category: String
    @State private var value: String
    @State private var unit: String

    /// The list of available categories ("All" removed)
    let categories: [String]

    let original: Habit?
    let onSave: (Habit, DateComponents?) -> Void
    @State private var reminderEnabled: Bool
    @State private var reminderTime: Date
    init(habit: Habit?, categories: [String], reminder: DateComponents?, onSave: @escaping (Habit, DateComponents?) -> Void) {
        self.original = habit
        self.categories = categories
        self.onSave = onSave
        _name = State(initialValue: habit?.name ?? "")
        _points = State(initialValue: habit?.points ?? 0)
        _type = State(initialValue: habit?.type ?? .good)
        _category = State(initialValue: habit?.category ?? categories.first ?? "")
        _value = State(initialValue: habit?.value.map { String($0) } ?? "")
        _unit = State(initialValue: habit?.unit ?? "")
        let date = Calendar.current.date(from: reminder ?? DateComponents(hour: 9, minute: 0)) ?? Date()
        _reminderEnabled = State(initialValue: reminder != nil)
        _reminderTime = State(initialValue: date)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    Stepper(value: $points, in: -100...100) {
                        HStack {
                            Text("Points")
                            Spacer()
                            Text("\(points)")
                        }
                    }
                    Picker("Type", selection: $type) {
                        ForEach(HabitType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    TextField("Value", text: $value)
                        .keyboardType(.numberPad)
                    TextField("Unit", text: $unit)
                }
                Section("Reminder") {
                    Toggle("Enable", isOn: $reminderEnabled)
                    if reminderEnabled {
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle(original == nil ? "Add Habit" : "Edit Habit")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let val = Int(value)
                        let habit = Habit(id: original?.id ?? UUID(),
                                          name: name,
                                          points: points,
                                          type: type,
                                          category: category,
                                          value: val,
                                          unit: unit.isEmpty ? nil : unit)
                        let comps = reminderEnabled ? Calendar.current.dateComponents([.hour, .minute], from: reminderTime) : nil
                        onSave(habit, comps)
                        dismiss()
                    }
                }
            }
        }
    }
}
