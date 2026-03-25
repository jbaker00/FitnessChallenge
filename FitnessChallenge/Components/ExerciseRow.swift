import SwiftUI

/// A single row displaying an exercise name, volume (sets×reps or duration), and optional notes.
struct ExerciseRow: View {
    let exercise: Exercise
    var index: Int = 0

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Index circle
            ZStack {
                Circle()
                    .fill(Color.electricBlue.opacity(0.15))
                    .frame(width: 34, height: 34)
                Text("\(index + 1)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.electricBlue)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(exercise.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    // Volume badge
                    Text(exercise.volumeSummary)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.electricBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.electricBlue.opacity(0.12))
                        .cornerRadius(6)
                }

                if !exercise.notes.isEmpty {
                    Text(exercise.notes)
                        .font(.system(size: 12))
                        .foregroundColor(.dimmedText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(10)
    }
}

#if DEBUG
struct ExerciseRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            VStack(spacing: 8) {
                ExerciseRow(
                    exercise: Exercise(name: "Push-ups", sets: 3, reps: 15, durationSeconds: 0, notes: "Keep core tight"),
                    index: 0
                )
                ExerciseRow(
                    exercise: Exercise(name: "Plank Hold", sets: 1, reps: 0, durationSeconds: 60, notes: ""),
                    index: 1
                )
            }
            .padding()
        }
    }
}
#endif
