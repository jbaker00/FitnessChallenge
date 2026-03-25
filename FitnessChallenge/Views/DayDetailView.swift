import SwiftUI

struct DayDetailView: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    let day: ChallengeDay

    @State private var markCompletePressed = false

    private var isCompleted: Bool { viewModel.isDayComplete(day.dayNumber) }

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: Hero header
                    heroHeader

                    // MARK: Workout section
                    workoutSection

                    // MARK: Exercises
                    if !day.exercises.isEmpty {
                        exercisesSection
                    }

                    // MARK: Nutrition tip
                    tipCard(
                        icon: "leaf.fill",
                        label: "NUTRITION TIP",
                        text: day.nutritionTip,
                        accentColor: .limeGreen
                    )

                    // MARK: Habit goal
                    tipCard(
                        icon: "target",
                        label: "HABIT GOAL",
                        text: day.habitGoal,
                        accentColor: .electricBlue
                    )

                    // MARK: Motivational quote
                    motivationalQuote

                    // MARK: Mark complete button
                    markCompleteButton

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Day \(day.dayNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.darkBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Hero header

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("DAY \(day.dayNumber)")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.electricBlue)
                    .tracking(2.5)
                Spacer()
                difficultyBadge
            }
            Text(day.title)
                .font(.system(size: 30, weight: .black))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Workout section

    private var workoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WORKOUT")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.dimmedText)
                .tracking(1.8)

            VStack(alignment: .leading, spacing: 10) {
                Text(day.workoutTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 20) {
                    metaItem(icon: "clock.fill", value: "\(day.durationMinutes) min", color: .electricBlue)
                    metaItem(icon: "flame.fill", value: "\(day.caloriesBurn) kcal", color: .limeGreen)
                    metaItem(icon: "figure.run", value: "\(day.exercises.count) exercises", color: .white.opacity(0.7))
                }

                if !day.workoutDescription.isEmpty {
                    Text(day.workoutDescription)
                        .font(.system(size: 14))
                        .foregroundColor(.dimmedText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
    }

    private func metaItem(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Exercises section

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EXERCISES")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.dimmedText)
                .tracking(1.8)

            VStack(spacing: 8) {
                ForEach(Array(day.exercises.enumerated()), id: \.offset) { index, exercise in
                    ExerciseRow(exercise: exercise, index: index)
                }
            }
        }
    }

    // MARK: - Tip cards

    private func tipCard(icon: String, label: String, text: String, accentColor: Color) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Left accent bar
            Rectangle()
                .fill(accentColor)
                .frame(width: 4)
                .cornerRadius(2)

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(accentColor)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 6) {
                    Text(label)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(accentColor)
                        .tracking(1.5)
                    Text(text)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Motivational quote

    private var motivationalQuote: some View {
        Group {
            if !day.motivationalQuote.isEmpty {
                Text("\"\(day.motivationalQuote)\"")
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(.dimmedText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Mark complete button

    private var markCompleteButton: some View {
        Button(action: toggleComplete) {
            HStack(spacing: 12) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                Text(isCompleted ? "COMPLETED" : "MARK DAY COMPLETE")
                    .font(.system(size: 15, weight: .black))
                    .tracking(1.2)
            }
            .foregroundColor(isCompleted ? .darkBackground : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isCompleted ? Color.limeGreen : Color.electricBlue)
            .cornerRadius(16)
            .scaleEffect(markCompletePressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: markCompletePressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            markCompletePressed = pressing
        }, perform: {})
    }

    private func toggleComplete() {
        if isCompleted {
            viewModel.unmarkDayComplete(day.dayNumber)
        } else {
            viewModel.markDayComplete(day.dayNumber)
        }
    }

    // MARK: - Difficulty badge

    private var difficultyBadge: some View {
        let color: Color = {
            switch day.difficulty.lowercased() {
            case "beginner":     return .limeGreen
            case "intermediate": return .electricBlue
            case "advanced":     return Color(red: 1, green: 0.27, blue: 0.27)
            default:             return .electricBlue
            }
        }()

        return Text(day.difficulty.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .cornerRadius(6)
    }
}

#if DEBUG
struct DayDetailView_Previews: PreviewProvider {
    static let sampleDay = ChallengeDay(
        id: "1",
        dayNumber: 1,
        challengeType: "7day",
        title: "Foundation Day",
        workoutTitle: "Full Body Activation",
        workoutDescription: "A light introductory workout to get the body moving and establish your baseline.",
        exercises: [
            Exercise(name: "Push-ups", sets: 3, reps: 15, durationSeconds: 0, notes: "Keep core engaged"),
            Exercise(name: "Bodyweight Squats", sets: 3, reps: 20, durationSeconds: 0, notes: ""),
            Exercise(name: "Plank Hold", sets: 3, reps: 0, durationSeconds: 45, notes: "Squeeze glutes"),
        ],
        nutritionTip: "Drink at least 2 litres of water throughout the day. Hydration is key to performance.",
        habitGoal: "Go to bed by 10 PM and aim for 8 hours of quality sleep.",
        motivationalQuote: "The secret of getting ahead is getting started.",
        difficulty: "Beginner",
        durationMinutes: 30,
        caloriesBurn: 220
    )

    static var previews: some View {
        NavigationStack {
            DayDetailView(day: sampleDay)
                .environmentObject(ChallengeViewModel())
        }
    }
}
#endif
