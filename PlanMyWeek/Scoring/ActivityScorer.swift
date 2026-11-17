import Foundation

enum ActivityScorer {
    static func rank(_ days: [DailyForecast], for activity: Activity) -> [DayScore] {
        days.map { score($0, for: activity) }
            .sorted { lhs, rhs in
                lhs.score != rhs.score ? lhs.score > rhs.score : lhs.day.date < rhs.day.date
            }
    }

    static func score(_ day: DailyForecast, for activity: Activity) -> DayScore {
        let assessment = switch activity {
        case .skiing: skiing(day)
        case .surfing: surfing(day)
        case .outdoorSightseeing: outdoorSightseeing(day)
        case .indoorSightseeing: indoorSightseeing(day)
        }
        return DayScore(day: day, activity: activity, score: assessment.score, reason: assessment.reason)
    }

    private static func skiing(_ day: DailyForecast) -> Assessment {
        var assessment = Assessment(
            goodReason: day.snowfallSum >= 5 ? "Fresh snow on a good base" : "Good snow cover and calm weather"
        )

        if day.snowDepthMax < 0.05 {
            if day.snowfallSum >= 5 {
                assessment.penalize(30, "Fresh snow but no base yet")
            } else {
                assessment.penalize(75, "Not enough snow for skiing")
            }
        } else {
            assessment.penalize(ramp(day.snowDepthMax, from: 0.5, to: 0.05, max: 40), "Thin snow cover")
        }

        assessment.penalize(ramp(day.temperatureMax, from: 3, to: 10, max: 30), "Too warm, snow will be slushy")
        assessment.penalize(ramp(day.temperatureMin, from: -20, to: -30, max: 20), "Extremely cold")
        assessment.penalize(ramp(day.rainSum, from: 0.5, to: 10, max: 30), "Rain expected on the slopes")
        assessment.penalize(ramp(day.windGustsMax, from: 40, to: 80, max: 30), "Strong gusts may close lifts")
        assessment.penalize(ramp(day.snowfallSum, from: 20, to: 40, max: 15), "Heavy snowfall, poor visibility")

        if day.condition == .thunderstorm {
            assessment.penalize(30, "Thunderstorms forecast")
        }
        if day.condition == .fog {
            assessment.penalize(10, "Fog, poor visibility")
        }

        return assessment
    }

    private static func surfing(_ day: DailyForecast) -> Assessment {
        var assessment = Assessment(goodReason: "Light winds and mild weather")

        assessment.penalize(ramp(day.windSpeedMax, from: 20, to: 45, max: 40), "Strong winds, choppy water")
        assessment.penalize(ramp(day.windGustsMax, from: 50, to: 80, max: 30), "Dangerous gusts")
        assessment.penalize(ramp(day.temperatureMax, from: 20, to: 5, max: 50), "Cold air, thick wetsuit needed")
        assessment.penalize(ramp(day.rainSum, from: 2, to: 20, max: 20), "Heavy rain")
        assessment.penalize(ramp(day.snowfallSum, from: 0.1, to: 2, max: 20), "Snow expected")

        if day.condition == .thunderstorm {
            assessment.penalize(60, "Thunderstorms, stay out of the water")
        }
        if day.condition == .fog {
            assessment.penalize(10, "Fog, poor visibility")
        }

        return assessment
    }

    private static func outdoorSightseeing(_ day: DailyForecast) -> Assessment {
        var assessment = Assessment(
            goodReason: day.sunshineHours >= 6 ? "Sunny and comfortable" : "Dry and comfortable"
        )

        assessment.penalize(ramp(day.precipitationProbabilityMax, from: 30, to: 90, max: 30), "High chance of rain")
        assessment.penalize(ramp(day.precipitationSum, from: 1, to: 15, max: 30), "Wet day")
        assessment.penalize(ramp(day.temperatureMax, from: 12, to: -5, max: 35), "Cold day")
        assessment.penalize(ramp(day.temperatureMax, from: 28, to: 40, max: 35), "Very hot day")
        assessment.penalize(ramp(day.windSpeedMax, from: 25, to: 60, max: 25), "Windy")
        assessment.penalize(ramp(day.sunshineHours, from: 6, to: 0, max: 15), "Little sunshine")
        assessment.penalize(ramp(day.snowfallSum, from: 1, to: 10, max: 20), "Snow expected")

        if day.condition == .thunderstorm {
            assessment.penalize(40, "Thunderstorms forecast")
        }
        if day.condition == .fog {
            assessment.penalize(10, "Foggy, limited views")
        }

        return assessment
    }

    private static func indoorSightseeing(_ day: DailyForecast) -> Assessment {
        let outdoorScore = outdoorSightseeing(day).score
        let goodReason = switch outdoorScore {
        case ..<40: "Poor weather outside, a great day for museums"
        case 40..<70: "Mixed weather, indoor plans work well"
        default: "Nice weather outside too, indoor is a fine backup"
        }

        var assessment = Assessment(goodReason: goodReason, base: 60 + 0.4 * Double(100 - outdoorScore))

        assessment.penalize(ramp(day.snowfallSum, from: 10, to: 30, max: 20), "Heavy snow may disrupt travel")
        assessment.penalize(ramp(day.windGustsMax, from: 70, to: 100, max: 15), "Storm-force gusts may disrupt travel")

        if day.condition == .thunderstorm {
            assessment.penalize(10, "Thunderstorms make getting around harder")
        }

        return assessment
    }

    private static func ramp(_ value: Double, from start: Double, to end: Double, max maximum: Double) -> Double {
        guard start != end else { return 0 }
        let progress = (value - start) / (end - start)
        return min(max(progress, 0), 1) * maximum
    }
}

private struct Assessment {
    let goodReason: String
    private var total: Double
    private var mainIssue: (amount: Double, reason: String)?

    init(goodReason: String, base: Double = 100) {
        self.goodReason = goodReason
        self.total = base
    }

    mutating func penalize(_ amount: Double, _ reason: String) {
        guard amount > 0 else { return }
        total -= amount
        if amount > (mainIssue?.amount ?? 0) {
            mainIssue = (amount, reason)
        }
    }

    var score: Int {
        Int(min(max(total, 0), 100).rounded())
    }

    var reason: String {
        guard score < 80, let mainIssue, mainIssue.amount >= 5 else {
            return goodReason
        }
        return mainIssue.reason
    }
}
