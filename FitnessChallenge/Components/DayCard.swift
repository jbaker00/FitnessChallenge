import SwiftUI

/// Compact card row used in AllDaysView.
struct DayCard: View {
    let day: ChallengeDay
    let isCompleted: Bool
    let isToday: Bool
    let isFuture: Bool

    var body: some View {
        HStack(spacing: 14) {
            // Day number indicator
            ZStack {
                Circle()
                    .fill(circleFill)
                    .frame(width: 44, height: 44)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(day.dayNumber)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(circleTextColor)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("DAY \(day.dayNumber)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isToday ? .electricBlue : .dimmedText)
                        .tracking(1.2)
                    if isToday {
                        Text("TODAY")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(.darkBackground)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.electricBlue)
                            .cornerRadius(4)
                    }
                }
                Text(day.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isFuture && !isToday ? .dimmedText : .white)

                Text(day.workoutTitle)
                    .font(.system(size: 12))
                    .foregroundColor(.dimmedText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                // Difficulty badge
                Text(day.difficulty)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(difficultyTextColor)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(difficultyBackground)
                    .cornerRadius(5)

                if isFuture && !isToday {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.dimmedText)
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isToday ? Color.electricBlue : Color.clear, lineWidth: 1.5)
        )
    }

    // MARK: - Styling helpers

    private var circleFill: Color {
        if isCompleted { return .limeGreen }
        if isToday { return .electricBlue }
        return Color.white.opacity(0.08)
    }

    private var circleTextColor: Color {
        if isToday { return .white }
        return .dimmedText
    }

    private var difficultyTextColor: Color {
        switch day.difficulty.lowercased() {
        case "beginner":     return .limeGreen
        case "intermediate": return .electricBlue
        case "advanced":     return Color(red: 1, green: 0.27, blue: 0.27)
        default:             return .electricBlue
        }
    }

    private var difficultyBackground: Color {
        difficultyTextColor.opacity(0.15)
    }
}

#if DEBUG
struct DayCard_Previews: PreviewProvider {
    static let sample = ChallengeDay(
        id: "1",
        dayNumber: 1,
        challengeType: "7day",
        title: "Foundation Day",
        workoutTitle: "Full Body Activation",
        workoutDescription: "A light intro workout.",
        exercises: [],
        nutritionTip: "Drink 2L of water.",
        habitGoal: "Sleep 8 hours.",
        motivationalQuote: "Start now.",
        difficulty: "Beginner",
        durationMinutes: 30,
        caloriesBurn: 200
    )

    static var previews: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            VStack(spacing: 10) {
                DayCard(day: sample, isCompleted: false, isToday: true, isFuture: false)
                DayCard(day: sample, isCompleted: true, isToday: false, isFuture: false)
                DayCard(day: sample, isCompleted: false, isToday: false, isFuture: true)
            }
            .padding()
        }
    }
}
#endif
