import Foundation

enum SuitabilityRating: Sendable, Hashable {
    case excellent
    case good
    case fair
    case poor

    init(score: Int) {
        switch score {
        case 80...: self = .excellent
        case 60..<80: self = .good
        case 40..<60: self = .fair
        default: self = .poor
        }
    }

    var title: String {
        switch self {
        case .excellent: "Excellent"
        case .good: "Good"
        case .fair: "Fair"
        case .poor: "Poor"
        }
    }
}

struct DayScore: Identifiable, Hashable, Sendable {
    let day: DailyForecast
    let activity: Activity
    let score: Int
    let reason: String

    var id: Date { day.date }

    var rating: SuitabilityRating { SuitabilityRating(score: score) }
}
