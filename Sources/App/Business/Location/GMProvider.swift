import Vapor
import Fluent

struct GMGeocodeResponse: Codable {
    var results: [GMGeocode]
}

struct GMGeocode: Codable {
    var formatted_address: String
    var address_components: [GMAddressComponent]
}

struct GMAddressComponent: Codable {
    var long_name: String
    var short_name: String
    var types: [String]?
}

enum GMType: String {
    case country
    case locality
}

struct GMProvider: LocationProvider {
    func getReverseGeocode(on request: Request, coordinate2D: Coordinate2DPosition) throws -> EventLoopFuture<Geolocation?> {
        guard let googleMapsApiKey = Environment.get("GOOGLE_MAPS_API_KEY") else {
            print("No google maps api key in enviroment")
            return Future.map(on: request) { return nil }
        }
        let client = try request.make(Client.self)
        guard let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinate2D.latitude),\(coordinate2D.longitude)&result_type=country|locality&language=en&key=\(googleMapsApiKey)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return Future.map(on: request) { return nil }
        }
        let response = client.get(url)
        
        let data = response.flatMap(to: GMGeocodeResponse.self) { response in
            return try response.content.decode(GMGeocodeResponse.self)
        }
        
        return data.flatMap { data in
            return Future.map(on: request) {
                guard let geo: GMGeocode = data.results.first else { return nil }
                let countryComponent = geo.address_components.first { $0.types?.first { $0 == GMType.country.rawValue } != nil }
                let cityComponent = geo.address_components.first { $0.types?.first { $0 == GMType.locality.rawValue } != nil }
                let countryCode = countryComponent?.short_name
                let country = countryComponent?.long_name
                let city = cityComponent?.short_name
                var flagURL: String?
                if let countryCode = countryCode {
                    flagURL = "https://flagpedia.net/data/flags/normal/\(countryCode).png"
                }
                return Geolocation(country: country, flagURL: flagURL, city: city)
            }
        }
    }
}
