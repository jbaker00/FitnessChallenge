import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class ChallengeViewModel: ObservableObject {

    // MARK: - Published state

    @Published var days: [ChallengeDay] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Persisted user state

    @AppStorage("challengeType") var challengeType: String = "7day" {
        didSet { Task { await fetchDays() } }
    }
    @AppStorage("challengeStartDate") var challengeStartDateString: String = ""
    @AppStorage("completedDays") var completedDaysString: String = ""

    // MARK: - Computed properties

    var completedDays: Set<Int> {
        guard !completedDaysString.isEmpty else { return [] }
        let parts = completedDaysString.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        return Set(parts)
    }

    var maxDays: Int {
        challengeType == "30day" ? 30 : 7
    }

    var progress: Double {
        guard maxDays > 0 else { return 0 }
        return min(Double(completedDays.count) / Double(maxDays), 1.0)
    }

    var isChallengeStarted: Bool {
        !challengeStartDateString.isEmpty
    }

    /// The current active day number (1-based), clamped to maxDays.
    var currentDayNumber: Int {
        guard !challengeStartDateString.isEmpty,
              let startDate = Self.dateFromString(challengeStartDateString) else {
            return 1
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: startDate)
        let components = calendar.dateComponents([.day], from: start, to: today)
        let daysSinceStart = (components.day ?? 0) + 1   // day 1 on start date
        return max(1, min(daysSinceStart, maxDays))
    }

    /// Consecutive days completed ending on or before today.
    var currentStreak: Int {
        var streak = 0
        var day = currentDayNumber
        while day >= 1 && completedDays.contains(day) {
            streak += 1
            day -= 1
        }
        return streak
    }

    /// Today's ChallengeDay object, if loaded.
    var todayDay: ChallengeDay? {
        days.first { $0.dayNumber == currentDayNumber }
    }

    /// Total estimated calories burned across all completed days.
    var totalCaloriesBurned: Int {
        days.filter { completedDays.contains($0.dayNumber) }
            .reduce(0) { $0 + $1.caloriesBurn }
    }

    // MARK: - Firestore

    private let db = Firestore.firestore()

    // MARK: - Init

    init() {
        Task { await fetchDays() }
    }

    // MARK: - Public methods

    func fetchDays() async {
        isLoading = true
        errorMessage = nil
        do {
            let snapshot = try await db.collection("fitness_challenges")
                .whereField("challengeType", isEqualTo: challengeType)
                .order(by: "dayNumber")
                .getDocuments()

            let fetched = snapshot.documents.compactMap { document -> ChallengeDay? in
                try? document.data(as: ChallengeDay.self)
            }
            days = fetched
        } catch {
            errorMessage = "Failed to load challenge data: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func markDayComplete(_ dayNumber: Int) {
        var current = completedDays
        current.insert(dayNumber)
        completedDaysString = current.sorted().map { String($0) }.joined(separator: ",")
    }

    func unmarkDayComplete(_ dayNumber: Int) {
        var current = completedDays
        current.remove(dayNumber)
        completedDaysString = current.sorted().map { String($0) }.joined(separator: ",")
    }

    func isDayComplete(_ dayNumber: Int) -> Bool {
        completedDays.contains(dayNumber)
    }

    func startChallenge() {
        challengeStartDateString = Self.stringFromDate(Date())
    }

    func resetChallenge() {
        completedDaysString = ""
        challengeStartDateString = ""
    }

    func switchChallengeType(to type: String) {
        resetChallenge()
        challengeType = type
    }

    // MARK: - Date helpers

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func dateFromString(_ string: String) -> Date? {
        dateFormatter.date(from: string)
    }

    static func stringFromDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
}
