import Foundation

struct RecentCitiesStore {
    let limit = 10

    private let defaults: UserDefaults
    private let key = "recentCities"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [Location] {
        guard let data = defaults.data(forKey: key),
              let locations = try? JSONDecoder().decode([Location].self, from: data)
        else { return [] }
        return locations
    }

    func save(_ locations: [Location]) {
        guard let data = try? JSONEncoder().encode(locations) else { return }
        defaults.set(data, forKey: key)
    }
}
