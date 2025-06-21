import SwiftUI

struct ModernButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color("PrimaryColor"), Color("SecondaryColor")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(configuration.isPressed ? 0.2 : 0.3), radius: configuration.isPressed ? 2 : 5, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
