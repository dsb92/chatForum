import Vapor
import Fluent

struct GMGeocodeResponse: Codable {
    var results: [GMGeocode]
}

struct GMGeocode: Codable {
    var formatted_address: String
}

struct GMProvider: LocationProvider {
    func getReverseGeocode(on request: Request, coordinate2D: Coordinate2DPosition) throws -> EventLoopFuture<Geolocation?> {
        guard let googleMapsApiKey = Environment.get("GOOGLE_MAPS_API_KEY") else {
            print("No google maps api key in enviroment")
            return Future.map(on: request) { return nil }
        }
        let client = try request.make(Client.self)
        let response = client.get("https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinate2D.latitude),\(coordinate2D.longitude)&result_type=country&key=\(googleMapsApiKey)")
        
        let data = response.flatMap(to: GMGeocodeResponse.self) { response in
            return try response.content.decode(GMGeocodeResponse.self)
        }

        return data.flatMap(to: Geolocation?.self) { data in
            return Future.map(on: request) {
                guard let geo: GMGeocode = data.results.first else { return nil }
                return Geolocation(country: geo.formatted_address, city: nil)
            }
        }
    }
}
