import Foundation

struct ForecastResponse: Decodable {
    let timezone: String
    let utcOffsetSeconds: Int
    let daily: Daily
    let hourly: Hourly?

    enum CodingKeys: String, CodingKey {
        case timezone, daily, hourly
        case utcOffsetSeconds = "utc_offset_seconds"
    }

    struct Daily: Decodable {
        let time: [String]
        let weatherCode: [Int?]?
        let temperatureMax: [Double?]?
        let temperatureMin: [Double?]?
        let precipitationSum: [Double?]?
        let rainSum: [Double?]?
        let snowfallSum: [Double?]?
        let precipitationProbabilityMax: [Double?]?
        let windSpeedMax: [Double?]?
        let windGustsMax: [Double?]?
        let sunshineDuration: [Double?]?

        enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperatureMax = "temperature_2m_max"
            case temperatureMin = "temperature_2m_min"
            case precipitationSum = "precipitation_sum"
            case rainSum = "rain_sum"
            case snowfallSum = "snowfall_sum"
            case precipitationProbabilityMax = "precipitation_probability_max"
            case windSpeedMax = "wind_speed_10m_max"
            case windGustsMax = "wind_gusts_10m_max"
            case sunshineDuration = "sunshine_duration"
        }
    }

    struct Hourly: Decodable {
        let time: [String]
        let snowDepth: [Double?]?

        enum CodingKeys: String, CodingKey {
            case time
            case snowDepth = "snow_depth"
        }
    }
}

extension ForecastResponse {
    func toForecast() -> Forecast {
        let timeZone = TimeZone(identifier: timezone)
            ?? TimeZone(secondsFromGMT: utcOffsetSeconds)
            ?? .gmt
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let snowDepthByDay = hourly?.maxSnowDepthByDay() ?? [:]

        let days = daily.time.indices.compactMap { i -> DailyForecast? in
            let day = daily.time[i]
            guard let date = Self.startOfDay(from: day, calendar: calendar),
                  let weatherCode = value(daily.weatherCode, i),
                  let temperatureMax = value(daily.temperatureMax, i),
                  let temperatureMin = value(daily.temperatureMin, i)
            else { return nil }

            return DailyForecast(
                date: date,
                weatherCode: weatherCode,
                temperatureMax: temperatureMax,
                temperatureMin: temperatureMin,
                precipitationSum: value(daily.precipitationSum, i) ?? 0,
                rainSum: value(daily.rainSum, i) ?? 0,
                snowfallSum: value(daily.snowfallSum, i) ?? 0,
                precipitationProbabilityMax: value(daily.precipitationProbabilityMax, i) ?? 0,
                windSpeedMax: value(daily.windSpeedMax, i) ?? 0,
                windGustsMax: value(daily.windGustsMax, i) ?? 0,
                sunshineDuration: value(daily.sunshineDuration, i) ?? 0,
                snowDepthMax: snowDepthByDay[day] ?? 0
            )
        }

        return Forecast(timeZone: timeZone, days: days)
    }

    static func startOfDay(from string: String, calendar: Calendar) -> Date? {
        let parts = string.prefix(10).split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }
}

extension ForecastResponse.Hourly {
    func maxSnowDepthByDay() -> [String: Double] {
        var result: [String: Double] = [:]
        for (i, timestamp) in time.enumerated() {
            guard let depth = value(snowDepth, i) else { continue }
            let day = String(timestamp.prefix(10))
            result[day] = max(result[day] ?? depth, depth)
        }
        return result
    }
}

private func value<T>(_ array: [T?]?, _ index: Int) -> T? {
    guard let array, array.indices.contains(index) else { return nil }
    return array[index]
}
