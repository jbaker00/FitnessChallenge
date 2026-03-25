import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    @State private var showResetConfirmation = false
    @State private var showSwitchConfirmation = false
    @State private var pendingSwitchType: String = ""

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // MARK: Avatar header
                        avatarHeader

                        // MARK: Stats card
                        statsCard

                        // MARK: Challenge type selector
                        challengeTypeCard

                        // MARK: Reset button
                        resetCard

                        // MARK: App info
                        appInfoCard

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Me")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.darkBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .confirmationDialog(
                "Reset Challenge",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset All Progress", role: .destructive) {
                    viewModel.resetChallenge()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will erase all your completed days and start date. Your challenge type preference will be kept.")
            }
            .confirmationDialog(
                "Switch Challenge Type",
                isPresented: $showSwitchConfirmation,
                titleVisibility: .visible
            ) {
                Button("Switch to \(pendingSwitchType == "7day" ? "7 Day" : "30 Day") (resets progress)", role: .destructive) {
                    viewModel.switchChallengeType(to: pendingSwitchType)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Switching challenge type will reset all your progress. Are you sure?")
            }
        }
    }

    // MARK: - Avatar header

    private var avatarHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.electricBlue, Color(red: 0.196, green: 0.843, blue: 0.294)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 34))
                    .foregroundColor(.white)
            }
            Text("Fitness Challenger")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            Text(viewModel.challengeType == "7day" ? "7-Day Challenge" : "30-Day Challenge")
                .font(.system(size: 13))
                .foregroundColor(.electricBlue)
        }
    }

    // MARK: - Stats card

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("YOUR PROGRESS")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statTile(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.completedDays.count)",
                    label: "Days Completed",
                    color: .limeGreen
                )
                statTile(
                    icon: "bolt.fill",
                    value: "\(viewModel.currentStreak)",
                    label: "Current Streak",
                    color: .electricBlue
                )
                statTile(
                    icon: "dumbbell.fill",
                    value: "\(viewModel.completedDays.count)",
                    label: "Total Workouts",
                    color: .electricBlue
                )
                statTile(
                    icon: "flame.fill",
                    value: "\(viewModel.totalCaloriesBurned)",
                    label: "Calories Burned",
                    color: Color(red: 1, green: 0.6, blue: 0.2)
                )
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    private func statTile(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.dimmedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.darkBackground)
        .cornerRadius(12)
    }

    // MARK: - Challenge type card

    private var challengeTypeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("CHALLENGE TYPE")

            HStack(spacing: 10) {
                challengeTypeButton(label: "7 DAY", type: "7day", subtitle: "Quick start")
                challengeTypeButton(label: "30 DAY", type: "30day", subtitle: "Full program")
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    private func challengeTypeButton(label: String, type: String, subtitle: String) -> some View {
        let isSelected = viewModel.challengeType == type
        return Button(action: {
            guard !isSelected else { return }
            pendingSwitchType = type
            showSwitchConfirmation = true
        }) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 14, weight: .black))
                    .tracking(1.2)
                    .foregroundColor(isSelected ? .darkBackground : .white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? Color.darkBackground.opacity(0.7) : .dimmedText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? Color.electricBlue : Color.darkBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.clear : Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }

    // MARK: - Reset card

    private var resetCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("DANGER ZONE")

            Button(action: { showResetConfirmation = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 18))
                    Text("Reset Challenge Progress")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.dimmedText)
                }
                .foregroundColor(Color(red: 1, green: 0.27, blue: 0.27))
                .padding(14)
                .background(Color(red: 1, green: 0.27, blue: 0.27).opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - App info card

    private var appInfoCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("APP INFO")

            HStack {
                Text("Version")
                    .font(.system(size: 14))
                    .foregroundColor(.dimmedText)
                Spacer()
                Text(appVersion)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 4)

            Divider().background(Color.white.opacity(0.06))

            HStack {
                Text("Challenge Type")
                    .font(.system(size: 14))
                    .foregroundColor(.dimmedText)
                Spacer()
                Text(viewModel.challengeType == "7day" ? "7 Day" : "30 Day")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.electricBlue)
            }
            .padding(.vertical, 4)

            Divider().background(Color.white.opacity(0.06))

            HStack {
                Text("Start Date")
                    .font(.system(size: 14))
                    .foregroundColor(.dimmedText)
                Spacer()
                Text(viewModel.challengeStartDateString.isEmpty ? "Not started" : viewModel.challengeStartDateString)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(viewModel.challengeStartDateString.isEmpty ? .dimmedText : .white)
            }
            .padding(.vertical, 4)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.dimmedText)
            .tracking(1.8)
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(ChallengeViewModel())
    }
}
#endif
