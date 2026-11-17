import Foundation
import Observation

@MainActor
@Observable
final class CitySearchViewModel {
    enum State: Equatable {
        case idle
        case loading
        case results([Location])
        case noResults
        case failed(String)
    }

    var query = ""
    private(set) var state: State = .idle
    private(set) var recentCities: [Location]

    private let service: any WeatherService
    private let recentStore: RecentCitiesStore
    private let minimumQueryLength = 2
    private let debounce: Duration = .milliseconds(300)

    init(service: any WeatherService, recentStore: RecentCitiesStore = RecentCitiesStore()) {
        self.service = service
        self.recentStore = recentStore
        self.recentCities = recentStore.load()
    }

    func addRecent(_ location: Location) {
        var cities = recentCities.filter { $0.id != location.id }
        cities.insert(location, at: 0)
        updateRecents(Array(cities.prefix(recentStore.limit)))
    }

    func removeRecents(at offsets: IndexSet) {
        var cities = recentCities
        for index in offsets.sorted(by: >) {
            cities.remove(at: index)
        }
        updateRecents(cities)
    }

    func clearRecents() {
        updateRecents([])
    }

    private func updateRecents(_ cities: [Location]) {
        recentCities = cities
        recentStore.save(cities)
    }

    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= minimumQueryLength else {
            state = .idle
            return
        }

        do {
            try await Task.sleep(for: debounce)
        } catch {
            return
        }

        state = .loading
        do {
            let locations = try await service.searchLocations(named: trimmed)
            state = locations.isEmpty ? .noResults : .results(locations)
        } catch is CancellationError {
            return
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
