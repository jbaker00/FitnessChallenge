import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    @State private var showTodaySheet = false
    @State private var navigateToToday = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // MARK: Header
                        headerSection

                        // MARK: Challenge type toggle
                        challengeTypeToggle

                        // MARK: Progress ring + day info
                        progressSection

                        // MARK: CTA Button
                        ctaButton

                        // MARK: Today preview
                        if viewModel.isChallengeStarted {
                            todayPreviewSection
                        }

                        // MARK: Recent completions
                        if !viewModel.completedDays.isEmpty {
                            recentCompletionsSection
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("FITNESS")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.electricBlue)
                    .tracking(3)
                Text("Challenge")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
            }
            Spacer()
            // Streak badge
            if viewModel.currentStreak > 0 {
                VStack(spacing: 2) {
                    Text("\(viewModel.currentStreak)")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.limeGreen)
                    Text("streak")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.dimmedText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.limeGreen.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.limeGreen.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Challenge type toggle

    private var challengeTypeToggle: some View {
        HStack(spacing: 0) {
            toggleButton(title: "7 DAY", type: "7day")
            toggleButton(title: "30 DAY", type: "30day")
        }
        .background(Color.cardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func toggleButton(title: String, type: String) -> some View {
        let isSelected = viewModel.challengeType == type
        return Button(action: {
            guard viewModel.challengeType != type else { return }
            viewModel.switchChallengeType(to: type)
        }) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .tracking(1.5)
                .foregroundColor(isSelected ? .darkBackground : .dimmedText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(isSelected ? Color.electricBlue : Color.clear)
                .cornerRadius(9)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .padding(3)
    }

    // MARK: - Progress section

    private var progressSection: some View {
        VStack(spacing: 20) {
            ZStack {
                CircularProgressView(
                    progress: viewModel.progress,
                    lineWidth: 14,
                    diameter: 190,
                    trackColor: Color.white.opacity(0.08),
                    progressColor: .electricBlue,
                    backgroundColor: Color.cardBackground
                )

                VStack(spacing: 4) {
                    Text("\(Int(viewModel.progress * 100))%")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("DAY \(viewModel.currentDayNumber) OF \(viewModel.maxDays)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.electricBlue)
                        .tracking(1.5)
                    Text("\(viewModel.completedDays.count) completed")
                        .font(.system(size: 12))
                        .foregroundColor(.dimmedText)
                }
            }

            // Stats row
            HStack(spacing: 0) {
                statItem(value: "\(viewModel.completedDays.count)", label: "Done")
                Divider()
                    .frame(height: 32)
                    .background(Color.white.opacity(0.1))
                statItem(value: "\(viewModel.maxDays - viewModel.completedDays.count)", label: "Left")
                Divider()
                    .frame(height: 32)
                    .background(Color.white.opacity(0.1))
                statItem(value: "\(viewModel.currentStreak)", label: "Streak")
            }
            .padding(.vertical, 14)
            .background(Color.cardBackground)
            .cornerRadius(14)
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.dimmedText)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.electricBlue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.cardBackground)
                    .cornerRadius(14)
            } else if !viewModel.isChallengeStarted {
                Button(action: { viewModel.startChallenge() }) {
                    HStack(spacing: 10) {
                        Image(systemName: "bolt.fill")
                        Text("START CHALLENGE")
                            .font(.system(size: 15, weight: .black))
                            .tracking(1.5)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.electricBlue)
                    .cornerRadius(14)
                }
            } else {
                NavigationLink(destination: TodayView().environmentObject(viewModel)) {
                    HStack(spacing: 10) {
                        Image(systemName: "flame.fill")
                        Text("CONTINUE TODAY")
                            .font(.system(size: 15, weight: .black))
                            .tracking(1.5)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [.electricBlue, Color(red: 0.0, green: 0.6, blue: 1.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }
            }
        }
    }

    // MARK: - Today preview

    private var todayPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY'S WORKOUT")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.dimmedText)
                .tracking(1.5)

            if let today = viewModel.todayDay {
                NavigationLink(destination: DayDetailView(day: today).environmentObject(viewModel)) {
                    todayCard(day: today)
                }
                .buttonStyle(PlainButtonStyle())
            } else if viewModel.isLoading {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .frame(height: 100)
                    .overlay(ProgressView().tint(.electricBlue))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .frame(height: 80)
                    .overlay(
                        Text("No workout data yet")
                            .font(.system(size: 14))
                            .foregroundColor(.dimmedText)
                    )
            }
        }
    }

    private func todayCard(day: ChallengeDay) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("DAY \(day.dayNumber)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.electricBlue)
                    .tracking(1.5)
                Text(day.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text(day.exerciseSummary)
                    .font(.system(size: 12))
                    .foregroundColor(.dimmedText)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text("\(day.caloriesBurn)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.limeGreen)
                Text("kcal")
                    .font(.system(size: 11))
                    .foregroundColor(.dimmedText)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.dimmedText)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.electricBlue.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Recent completions

    private var recentCompletionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT COMPLETIONS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.dimmedText)
                .tracking(1.5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.completedDays.sorted().suffix(10), id: \.self) { dayNum in
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color.limeGreen.opacity(0.2))
                                    .frame(width: 42, height: 42)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.limeGreen)
                            }
                            Text("\(dayNum)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.dimmedText)
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(ChallengeViewModel())
    }
}
#endif
