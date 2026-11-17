import SwiftUI

struct DayScoreRow: View {
    let rank: Int
    let dayScore: DayScore
    let timeZone: TimeZone

    private var day: DailyForecast { dayScore.day }
    private var isBest: Bool { rank == 1 }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 20)

            Image(systemName: day.condition.symbolName)
                .symbolVariant(.fill)
                .symbolRenderingMode(.multicolor)
                .font(.title2)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(dayTitle)
                        .font(.headline)
                    if isBest {
                        Text("Best day")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(dayScore.rating.color.opacity(0.2), in: Capsule())
                            .foregroundStyle(dayScore.rating.color)
                    }
                }
                Text(dayScore.reason)
                    .font(.subheadline)
                Text("\(day.condition.description) · \(temperature(day.temperatureMin)) / \(temperature(day.temperatureMax))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            VStack(spacing: 2) {
                Text("\(dayScore.score)")
                    .font(.title3.bold())
                    .monospacedDigit()
                Text(dayScore.rating.title)
                    .font(.caption2)
            }
            .foregroundStyle(dayScore.rating.color)
            .frame(minWidth: 56)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private var dayTitle: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        if calendar.isDateInToday(day.date) {
            return "Today"
        }
        if calendar.isDateInTomorrow(day.date) {
            return "Tomorrow"
        }
        var style = Date.FormatStyle.dateTime.weekday(.abbreviated).day().month(.abbreviated)
        style.timeZone = timeZone
        return day.date.formatted(style)
    }

    private func temperature(_ celsius: Double) -> String {
        "\(Int(celsius.rounded()))°"
    }
}

extension SuitabilityRating {
    var color: Color {
        switch self {
        case .excellent: .green
        case .good: .teal
        case .fair: .orange
        case .poor: .red
        }
    }
}
