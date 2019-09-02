import Vapor
import Fluent

final class LocationController: RouteCollection {
    func boot(router: Router) throws {
        let locs = router.grouped("locations")
        
        locs.get(use: getLocations)
        locs.get("/distinctByCountry", use: getDistinctLocationsByCountry)
    }
    
    func getLocations(_ request: Request)throws -> Future<LocationsResponse> {
        let val = Location.query(on: request).all()
        
        return val.flatMap { locations in
            let all = self.sortedByCountryAscending(locations: locations)
            return Future.map(on: request) { return all }
        }
    }
    
    func getDistinctLocationsByCountry(_ request: Request)throws -> Future<LocationsDistinctCountryResponse> {
        return Location.query(on: request).all().flatMap { locations in
            var distinct = [Location.DistinctCountry]()
            let promise: Promise<LocationsDistinctCountryResponse> = request.eventLoop.newPromise()
            DispatchQueue.global().async {
                locations.forEach { location in
                    let exists = distinct.first { $0.country == location.country }
                    
                    if exists == nil {
                        distinct.append(Location.DistinctCountry(country: location.country, flagURL: location.flagURL))
                    }
                }
                
                promise.succeed(result: self.sortedDistinctByCountryAscending(locations: distinct))
            }
            
            return promise.futureResult
        }
    }
    
    private func sortedByCountryAscending(locations: [Location]) -> LocationsResponse {
        return LocationsResponse(locations: locations.sorted(by: { (l, r) -> Bool in
            return l.country < r.country
        }))
    }
    
    private func sortedDistinctByCountryAscending(locations: [Location.DistinctCountry]) -> LocationsDistinctCountryResponse {
        return LocationsDistinctCountryResponse(locations: locations.sorted(by: { (l, r) -> Bool in
            return l.country < r.country
        }))
    }
}
