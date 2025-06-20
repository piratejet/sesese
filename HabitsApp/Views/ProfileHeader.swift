import SwiftUI

struct ProfileHeader: View {
    @EnvironmentObject var viewModel: HabitViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    if viewModel.userName.isEmpty {
                        Text("Welcome")
                            .font(.headline)
                    } else {
                        Text("Hello, \(viewModel.userName)")
                            .font(.headline)
                    }
                    Text("Your Progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            HStack(spacing: 30) {
                VStack(alignment: .leading) {
                    Text("Points")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.totalPoints)")
                        .font(.headline)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Gems")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.gems)")
                        .font(.headline)
                }
            }

            Stepper(value: Binding(
                get: { viewModel.dailyTarget },
                set: { viewModel.updateDailyTarget($0) }
            ), in: 10...1000, step: 10) {
                HStack {
                    Text("Daily Target")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(viewModel.dailyTarget) pts")
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
