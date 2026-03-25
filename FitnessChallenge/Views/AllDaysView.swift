import SwiftUI

struct AllDaysView: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    @State private var selectedDay: ChallengeDay? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()

                if viewModel.isLoading {
                    loadingView
                } else if viewModel.days.isEmpty {
                    emptyView
                } else {
                    daysList
                }
            }
            .navigationTitle("All Days")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.darkBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { Task { await viewModel.fetchDays() } }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.electricBlue)
                    }
                }
            }
        }
    }

    // MARK: - Days list

    private var daysList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Summary header
                summaryHeader
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                LazyVStack(spacing: 10) {
                    ForEach(viewModel.days) { day in
                        let isCompleted = viewModel.isDayComplete(day.dayNumber)
                        let isToday = day.dayNumber == viewModel.currentDayNumber && viewModel.isChallengeStarted
                        let isFuture = day.dayNumber > viewModel.currentDayNumber && viewModel.isChallengeStarted

                        NavigationLink(destination: DayDetailView(day: day).environmentObject(viewModel)) {
                            DayCard(
                                day: day,
                                isCompleted: isCompleted,
                                isToday: isToday,
                                isFuture: isFuture
                            )
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Summary header

    private var summaryHeader: some View {
        HStack(spacing: 0) {
            summaryCell(
                value: "\(viewModel.completedDays.count)",
                label: "Done",
                color: .limeGreen
            )
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1, height: 36)
            summaryCell(
                value: "\(viewModel.maxDays - viewModel.completedDays.count)",
                label: "Left",
                color: .electricBlue
            )
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1, height: 36)
            summaryCell(
                value: "\(viewModel.days.count)",
                label: "Total",
                color: .dimmedText
            )
        }
        .padding(.vertical, 14)
        .background(Color.cardBackground)
        .cornerRadius(14)
    }

    private func summaryCell(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(color)
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.dimmedText)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Loading / empty states

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.electricBlue)
                .scaleEffect(1.4)
            Text("Loading challenge days...")
                .font(.system(size: 14))
                .foregroundColor(.dimmedText)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.slash.fill")
                .font(.system(size: 52))
                .foregroundColor(.dimmedText)
            Text("No Days Found")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Text("Make sure the \(viewModel.challengeType) challenge has been set up in Firebase.")
                .font(.system(size: 14))
                .foregroundColor(.dimmedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: { Task { await viewModel.fetchDays() } }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(Color.electricBlue)
                .cornerRadius(12)
            }
        }
    }
}

#if DEBUG
struct AllDaysView_Previews: PreviewProvider {
    static var previews: some View {
        AllDaysView()
            .environmentObject(ChallengeViewModel())
    }
}
#endif
