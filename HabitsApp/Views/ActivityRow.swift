import SwiftUI

struct ActivityRow: View {
    let habit: Habit
    let date: Date?
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
                if let d = date {
                    Text(d, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text("\(habit.points > 0 ? "+" : "")\(habit.points) pts")
                .bold()
                .foregroundColor(habit.points > 0 ? .green : .red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .shadow(radius: 1)
        .swipeActions {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
