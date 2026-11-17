import Foundation

struct OpenMeteoClient: WeatherService {
    static let geocodingBaseURL = URL(string: "https://geocoding-api.open-meteo.com/v1/search")!
    static let forecastBaseURL = URL(string: "https://api.open-meteo.com/v1/forecast")!

    static let forecastDays = 7
    static let searchResultLimit = 10
    static let minimumQueryLength = 2

    static let dailyVariables = [
        "weather_code",
        "temperature_2m_max",
        "temperature_2m_min",
        "precipitation_sum",
        "rain_sum",
        "snowfall_sum",
        "precipitation_probability_max",
        "wind_speed_10m_max",
        "wind_gusts_10m_max",
        "sunshine_duration",
    ]

    static let hourlyVariables = ["snow_depth"]

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchLocations(named query: String) async throws -> [Location] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= Self.minimumQueryLength else { return [] }

        let data = try await fetch(Self.geocodingURL(for: trimmed))
        return try Self.decodeLocations(from: data)
    }

    func forecast(for location: Location) async throws -> Forecast {
        let url = Self.forecastURL(latitude: location.latitude, longitude: location.longitude)
        let data = try await fetch(url)
        return try Self.decodeForecast(from: data)
    }

    static func geocodingURL(for query: String, language: String = "en") -> URL {
        geocodingBaseURL.appending(queryItems: [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: String(searchResultLimit)),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "format", value: "json"),
        ])
    }

    static func forecastURL(latitude: Double, longitude: Double) -> URL {
        forecastBaseURL.appending(queryItems: [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "daily", value: dailyVariables.joined(separator: ",")),
            URLQueryItem(name: "hourly", value: hourlyVariables.joined(separator: ",")),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: String(forecastDays)),
        ])
    }

    static func decodeLocations(from data: Data) throws -> [Location] {
        do {
            return try JSONDecoder().decode(GeocodingResponse.self, from: data).results ?? []
        } catch {
            throw WeatherServiceError.decoding(underlying: error)
        }
    }

    static func decodeForecast(from data: Data) throws -> Forecast {
        do {
            return try JSONDecoder().decode(ForecastResponse.self, from: data).toForecast()
        } catch {
            throw WeatherServiceError.decoding(underlying: error)
        }
    }

    static func validate(data: Data, response: URLResponse) throws -> Data {
        guard let http = response as? HTTPURLResponse else {
            throw WeatherServiceError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let reason = try? JSONDecoder().decode(APIErrorBody.self, from: data).reason
            throw WeatherServiceError.server(statusCode: http.statusCode, reason: reason)
        }
        return data
    }

    private func fetch(_ url: URL) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            throw WeatherServiceError.network(underlying: error)
        }
        return try Self.validate(data: data, response: response)
    }
}

private struct APIErrorBody: Decodable {
    let reason: String
}
