import Foundation

enum Activity: String, CaseIterable, Identifiable, Hashable, Sendable {
    case skiing
    case surfing
    case outdoorSightseeing
    case indoorSightseeing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .skiing: "Skiing"
        case .surfing: "Surfing"
        case .outdoorSightseeing: "Outdoor sightseeing"
        case .indoorSightseeing: "Indoor sightseeing"
        }
    }

    var shortTitle: String {
        switch self {
        case .skiing: "Ski"
        case .surfing: "Surf"
        case .outdoorSightseeing: "Outdoor"
        case .indoorSightseeing: "Indoor"
        }
    }

    var symbolName: String {
        switch self {
        case .skiing: "figure.skiing.downhill"
        case .surfing: "figure.surfing"
        case .outdoorSightseeing: "binoculars"
        case .indoorSightseeing: "building.columns"
        }
    }

    var note: String? {
        switch self {
        case .surfing: "Based on wind and weather only. Wave conditions are not included."
        case .skiing: "Based on snow and weather at the searched location."
        case .outdoorSightseeing, .indoorSightseeing: nil
        }
    }
}
