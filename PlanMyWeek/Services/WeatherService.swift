import Foundation

protocol WeatherService: Sendable {
    func searchLocations(named query: String) async throws -> [Location]

    func forecast(for location: Location) async throws -> Forecast
}

enum WeatherServiceError: LocalizedError {
    case network(underlying: any Error)
    case invalidResponse
    case server(statusCode: Int, reason: String?)
    case decoding(underlying: any Error)

    var errorDescription: String? {
        switch self {
        case .network:
            "Couldn't reach the weather service. Check your connection and try again."
        case .invalidResponse:
            "The weather service sent an invalid response."
        case .server(let statusCode, let reason):
            if let reason, !reason.isEmpty {
                "The weather service returned an error (\(statusCode)): \(reason)"
            } else {
                "The weather service returned an error (\(statusCode))."
            }
        case .decoding:
            "The weather service sent data the app couldn't read."
        }
    }
}
