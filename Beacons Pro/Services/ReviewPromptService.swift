import Foundation
import Observation

/// Tracks meaningful user activity and decides when the app has earned
/// the right to ask for an App Store review.
///
/// Engagement is recorded as weighted events. The prompt itself is only
/// surfaced at a calm moment — right after the user finishes a task —
/// and only once every eligibility gate passes: enough engagement,
/// enough distinct days of use, not the first day, not recently asked,
/// and not already asked on this app version.
@Observable
final class ReviewPromptService {
    enum Event {
        /// The user stopped a scan session that discovered beacons.
        case scanSessionCompleted
        /// The user saved a discovered beacon to their fleet.
        case beaconSaved
        /// The user started broadcasting as an iBeacon.
        case broadcastStarted
        /// The user exported their data (JSON or CSV).
        case dataExported

        var points: Int {
            switch self {
            case .scanSessionCompleted: 1
            case .beaconSaved: 2
            case .broadcastStarted: 2
            case .dataExported: 3
            }
        }
    }

    /// Set when a calm moment finds all eligibility gates passing.
    /// The view layer observes this and presents the system prompt.
    private(set) var promptPending = false

    private let defaults: UserDefaults
    private let calendar = Calendar.current

    private enum Key {
        static let firstUseDate = "review.firstUseDate"
        static let lastUsageDay = "review.lastUsageDay"
        static let usageDayCount = "review.usageDayCount"
        static let engagementScore = "review.engagementScore"
        static let lastPromptDate = "review.lastPromptDate"
        static let lastPromptVersion = "review.lastPromptVersion"
    }

    private static let minimumScore = 4
    private static let minimumUsageDays = 2
    private static let minimumDaysSinceFirstUse = 2
    /// Apple allows at most 3 prompts per rolling 365 days.
    private static let promptCooldownDays = 122

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: Key.firstUseDate) == nil {
            defaults.set(Date.now, forKey: Key.firstUseDate)
        }
        recordUsageDay()
    }

    // MARK: - Recording activity

    func record(_ event: Event) {
        recordUsageDay()
        let score = defaults.integer(forKey: Key.engagementScore) + event.points
        defaults.set(score, forKey: Key.engagementScore)
    }

    /// Call at a natural pause after the user completes a task (stopping
    /// a productive scan or broadcast, dismissing an export sheet). The
    /// prompt only ever fires here, never mid-task.
    func promptAtCalmMomentIfEarned() {
        guard isEligible else { return }
        promptPending = true
    }

    /// Called by the view layer once the system prompt has been requested.
    func markPrompted() {
        promptPending = false
        defaults.set(Date.now, forKey: Key.lastPromptDate)
        defaults.set(Self.currentVersion, forKey: Key.lastPromptVersion)
        defaults.set(0, forKey: Key.engagementScore)
    }

    // MARK: - Eligibility

    private var isEligible: Bool {
        guard !promptPending else { return false }
        guard defaults.integer(forKey: Key.engagementScore) >= Self.minimumScore else { return false }
        guard defaults.integer(forKey: Key.usageDayCount) >= Self.minimumUsageDays else { return false }
        guard let firstUse = defaults.object(forKey: Key.firstUseDate) as? Date,
              days(from: firstUse) >= Self.minimumDaysSinceFirstUse else { return false }
        if let lastPrompt = defaults.object(forKey: Key.lastPromptDate) as? Date {
            guard days(from: lastPrompt) >= Self.promptCooldownDays else { return false }
            guard defaults.string(forKey: Key.lastPromptVersion) != Self.currentVersion else { return false }
        }
        return true
    }

    // MARK: - Helpers

    private func recordUsageDay() {
        let stamp = dayStamp(for: .now)
        guard defaults.string(forKey: Key.lastUsageDay) != stamp else { return }
        defaults.set(stamp, forKey: Key.lastUsageDay)
        defaults.set(defaults.integer(forKey: Key.usageDayCount) + 1, forKey: Key.usageDayCount)
    }

    private func dayStamp(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }

    private func days(from date: Date) -> Int {
        calendar.dateComponents([.day], from: date, to: .now).day ?? 0
    }

    private static var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
    }
}
