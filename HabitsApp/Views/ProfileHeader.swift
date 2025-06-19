import SwiftUI

struct ProfileHeader: View {
    @EnvironmentObject var viewModel: HabitViewModel

    var body: some View {
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
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
