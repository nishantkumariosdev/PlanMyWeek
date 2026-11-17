import Foundation

enum WeatherCondition: Sendable, Equatable {
    case clear
    case mainlyClear
    case partlyCloudy
    case overcast
    case fog
    case drizzle
    case freezingRain
    case rain
    case heavyRain
    case snow
    case heavySnow
    case thunderstorm
    case unknown

    init(code: Int) {
        switch code {
        case 0: self = .clear
        case 1: self = .mainlyClear
        case 2: self = .partlyCloudy
        case 3: self = .overcast
        case 45, 48: self = .fog
        case 51, 53, 55: self = .drizzle
        case 56, 57, 66, 67: self = .freezingRain
        case 61, 63, 80, 81: self = .rain
        case 65, 82: self = .heavyRain
        case 71, 73, 77, 85: self = .snow
        case 75, 86: self = .heavySnow
        case 95, 96, 99: self = .thunderstorm
        default: self = .unknown
        }
    }

    var description: String {
        switch self {
        case .clear: "Clear sky"
        case .mainlyClear: "Mainly clear"
        case .partlyCloudy: "Partly cloudy"
        case .overcast: "Overcast"
        case .fog: "Fog"
        case .drizzle: "Drizzle"
        case .freezingRain: "Freezing rain"
        case .rain: "Rain"
        case .heavyRain: "Heavy rain"
        case .snow: "Snow"
        case .heavySnow: "Heavy snow"
        case .thunderstorm: "Thunderstorm"
        case .unknown: "Unknown"
        }
    }

    var symbolName: String {
        switch self {
        case .clear: "sun.max"
        case .mainlyClear: "sun.max"
        case .partlyCloudy: "cloud.sun"
        case .overcast: "cloud"
        case .fog: "cloud.fog"
        case .drizzle: "cloud.drizzle"
        case .freezingRain: "cloud.sleet"
        case .rain: "cloud.rain"
        case .heavyRain: "cloud.heavyrain"
        case .snow: "cloud.snow"
        case .heavySnow: "snowflake"
        case .thunderstorm: "cloud.bolt.rain"
        case .unknown: "questionmark"
        }
    }
}
