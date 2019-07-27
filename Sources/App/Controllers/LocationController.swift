import Vapor
import Fluent

final class LocationController: RouteCollection {
    func boot(router: Router) throws {
        let locs = router.grouped("locations")
        
        locs.get(use: getLocations)
    }
    
    func getLocations(_ request: Request)throws -> Future<LocationsResponse> {
        let val = Location.query(on: request).all()
        return val.flatMap { locations in
            let all = LocationsResponse(locations: locations.sorted(by: { (l, r) -> Bool in
                return l.country < r.country
            }))
            return Future.map(on: request) { return all }
        }
    }
}
