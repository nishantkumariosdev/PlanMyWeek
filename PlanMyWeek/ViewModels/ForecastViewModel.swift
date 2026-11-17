import Foundation
import Observation

@MainActor
@Observable
final class ForecastViewModel {
    enum State {
        case loading
        case loaded(Forecast)
        case failed(String)
    }

    let location: Location
    var selectedActivity: Activity = .skiing
    private(set) var state: State = .loading

    private let service: any WeatherService
    private var hasLoaded = false

    init(location: Location, service: any WeatherService) {
        self.location = location
        self.service = service
    }

    var rankedDays: [DayScore] {
        guard case .loaded(let forecast) = state else { return [] }
        return ActivityScorer.rank(forecast.days, for: selectedActivity)
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await load()
    }

    func load() async {
        if case .failed = state {
            state = .loading
        }
        do {
            let forecast = try await service.forecast(for: location)
            state = .loaded(forecast)
            hasLoaded = true
        } catch is CancellationError {
            return
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
