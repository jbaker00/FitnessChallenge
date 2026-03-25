import SwiftUI

struct TodayView: View {
    @EnvironmentObject var viewModel: ChallengeViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()

                if viewModel.isLoading {
                    loadingView
                } else if let day = viewModel.todayDay {
                    DayDetailView(day: day)
                        .environmentObject(viewModel)
                } else if !viewModel.isChallengeStarted {
                    notStartedView
                } else {
                    emptyView
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.darkBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.electricBlue)
                .scaleEffect(1.4)
            Text("Loading workout...")
                .font(.system(size: 14))
                .foregroundColor(.dimmedText)
        }
    }

    private var notStartedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.electricBlue)
            Text("Ready to Start?")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.white)
            Text("Go to Dashboard to begin your challenge.")
                .font(.system(size: 15))
                .foregroundColor(.dimmedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.electricBlue.opacity(0.7))
            Text("No Workout Today")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            Text("Could not load Day \(viewModel.currentDayNumber)'s content.\nCheck your connection and try again.")
                .font(.system(size: 14))
                .foregroundColor(.dimmedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: { Task { await viewModel.fetchDays() } }) {
                Text("Retry")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.electricBlue)
            }
        }
    }
}
