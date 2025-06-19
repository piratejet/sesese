import SwiftUI

struct ProgressRing: View {
    var progress: Double
    var colors: [Color] = [.blue, .green]
    var body: some View {
        ZStack {
            Circle().stroke(lineWidth: 10).opacity(0.3).foregroundColor(colors.first)
            Circle().trim(from: 0, to: progress)
                .stroke(AngularGradient(gradient: .init(colors: colors), center: .center,
                    startAngle: .degrees(0), endAngle: .degrees(360)), style: .init(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.title2.bold())
        }
    }
}
