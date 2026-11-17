import Foundation

struct Forecast: Hashable, Sendable {
    let timeZone: TimeZone
    let days: [DailyForecast]
}

struct DailyForecast: Identifiable, Hashable, Sendable {
    let date: Date
    let weatherCode: Int
    let temperatureMax: Double
    let temperatureMin: Double
    let precipitationSum: Double
    let rainSum: Double
    let snowfallSum: Double
    let precipitationProbabilityMax: Double
    let windSpeedMax: Double
    let windGustsMax: Double
    let sunshineDuration: TimeInterval
    let snowDepthMax: Double

    var id: Date { date }

    var condition: WeatherCondition { WeatherCondition(code: weatherCode) }

    var sunshineHours: Double { sunshineDuration / 3600 }
}
