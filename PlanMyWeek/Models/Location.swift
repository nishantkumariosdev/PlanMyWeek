import Foundation

struct Location: Identifiable, Hashable, Sendable, Codable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let elevation: Double?
    let timezone: String?
    let countryCode: String?
    let country: String?
    let admin1: String?

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, elevation, timezone, country, admin1
        case countryCode = "country_code"
    }

    var subtitle: String {
        [admin1, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    var flagEmoji: String? {
        guard let code = countryCode?.uppercased(),
              code.unicodeScalars.count == 2,
              code.unicodeScalars.allSatisfy({ ("A"..."Z").contains($0) })
        else { return nil }

        let regionalIndicatorOffset: UInt32 = 0x1F1E6 - 0x41
        let scalars = code.unicodeScalars.compactMap { Unicode.Scalar($0.value + regionalIndicatorOffset) }
        return String(String.UnicodeScalarView(scalars))
    }
}

struct GeocodingResponse: Decodable {
    let results: [Location]?
}
