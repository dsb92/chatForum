import Vapor

struct LocationsResponse: Codable {
    var locations: [Location]
}
extension LocationsResponse: Content { }
