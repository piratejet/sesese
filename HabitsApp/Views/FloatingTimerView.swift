import SwiftUI

struct FloatingTimerView: View {
    @EnvironmentObject var timerState: TimerState
    @State private var position: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero

    private var formattedTime: String {
        let totalSeconds = Int(timerState.elapsed)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        Text(formattedTime)
            .font(.headline.monospacedDigit())
            .frame(width: 60, height: 60)
            .background(Color.blue.opacity(0.9))
            .foregroundColor(.white)
            .clipShape(Circle())
            .offset(x: position.width + dragOffset.width,
                    y: position.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        position.width += value.translation.width
                        position.height += value.translation.height
                    }
            )
            .onTapGesture {
                timerState.isMinimized = false
                timerState.showTimerView = true
            }
    }
}
