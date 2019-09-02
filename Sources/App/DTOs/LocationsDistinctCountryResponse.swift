import Vapor

struct LocationsDistinctCountryResponse: Codable {
    var locations: [Location.DistinctCountry]
}
extension LocationsDistinctCountryResponse: Content { }
