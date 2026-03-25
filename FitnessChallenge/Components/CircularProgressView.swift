import SwiftUI

/// A circular ring progress indicator.
struct CircularProgressView: View {
    let progress: Double          // 0.0 – 1.0
    var lineWidth: CGFloat = 14
    var diameter: CGFloat = 180
    var trackColor: Color = Color.white.opacity(0.1)
    var progressColor: Color = .electricBlue
    var backgroundColor: Color = .clear

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Background circle fill
            Circle()
                .fill(backgroundColor)
                .frame(width: diameter, height: diameter)

            // Track ring
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
                .frame(width: diameter, height: diameter)

            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: diameter, height: diameter)
                .animation(.easeInOut(duration: 0.8), value: animatedProgress)
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeInOut(duration: 0.6)) {
                animatedProgress = newValue
            }
        }
    }
}

#if DEBUG
struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            CircularProgressView(progress: 0.65)
        }
    }
}
#endif
