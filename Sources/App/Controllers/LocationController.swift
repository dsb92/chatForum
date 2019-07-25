import Vapor
import Fluent

struct LocationResponse: Codable {
    var locations: [Location]
}

extension LocationResponse: Content { }

final class LocationController: RouteCollection {
    func boot(router: Router) throws {
        let locs = router.grouped("posts/locations")
        
        locs.get(use: getLocations)
    }
    
    func getLocations(_ request: Request)throws -> Future<LocationResponse> {
        let val = Location.query(on: request).all()
        return val.flatMap { locations in
            let all = LocationResponse(locations: locations.sorted(by: { (l, r) -> Bool in
                return l.country < r.country
            }))
            return Future.map(on: request) { return all }
        }
    }
}
