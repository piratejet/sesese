import SwiftUI

struct FloatingTimerView: View {
    @EnvironmentObject var timerState: TimerState
    @State private var offset: CGSize = .zero

    private var formattedTime: String {
        let totalSeconds = Int(timerState.elapsed)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        Text(formattedTime)
            .font(.caption2.monospacedDigit())
            .padding(12)
            .background(Color.blue.opacity(0.9))
            .foregroundColor(.white)
            .clipShape(Circle())
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
            )
            .onTapGesture {
                timerState.isMinimized = false
                timerState.showTimerView = true
            }
    }
}
