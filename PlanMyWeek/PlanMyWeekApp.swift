import SwiftUI

@main
struct PlanMyWeekApp: App {
    var body: some Scene {
        WindowGroup {
            CitySearchView(service: OpenMeteoClient())
        }
    }
}
