import SwiftUI

struct ActivityRow: View {
    let habit: Habit
    let onDelete: () -> Void
    var body: some View {
        HStack {
            Image(systemName: habit.type == .good ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(habit.type == .good ? .green : .red)
            VStack(alignment: .leading) {
                Text(habit.name)
                if let value = habit.value, let unit = habit.unit {
                    Text("\(value) \(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text("\(habit.points > 0 ? "+" : "")\(habit.points) pts")
                .bold().foregroundColor(habit.points > 0 ? .green : .red)
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill").foregroundColor(.red)
            }
        }
        .padding().background(Color(.systemGray6)).cornerRadius(8)
    }
}
