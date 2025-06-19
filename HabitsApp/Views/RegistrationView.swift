import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @State private var name:  String = ""
    @State private var email: String = ""
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Welcome!")) {
                    Text("Please enter your name and email to get started.")
                        .font(.subheadline)
                }
                Section("Your Info") {
                    TextField("Full Name", text: $name)
                    TextField("Email",     text: $email)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle("Get Started")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Continue") {
                        guard !name.isEmpty, !email.isEmpty else {
                            showAlert = true
                            return
                        }
                        viewModel.register(name: name, email: email)
                    }
                }
            }
            .alert("All fields required", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please fill in both your name and email.")
            }
        }
    }
}
