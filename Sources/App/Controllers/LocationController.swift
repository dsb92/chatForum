import Vapor
import Fluent

final class LocationController: RouteCollection {
    struct Params {
        static let country = "country"
    }
    
    func boot(router: Router) throws {
        let locs = router.grouped("locations")
        
        locs.get(use: getLocations)
        locs.get("/distinct", use: getDistinctLocationsByCountry)
    }
    
    func getLocations(_ request: Request)throws -> Future<LocationsResponse> {
        guard let queryCountry = request.query[String.self, at: Params.country] else {
            let val = Location.query(on: request).all()
            
            return val.flatMap { locations in
                return try self.sortedByCountryAscendingRequest(request: request, locations: locations)
            }
        }
        
        return try getLocationsByCountry(request, country: queryCountry)
    }
    
    func getLocationsByCountry(_ request: Request, country: String)throws -> Future<LocationsResponse> {
        return Location.query(on: request).filter(\Location.country, .equal, country).all().flatMap { locations in
            return try self.sortedByCountryAscendingRequest(request: request, locations: locations)
        }
    }
    
    func getDistinctLocationsByCountry(_ request: Request)throws -> Future<LocationsDistinctCountryResponse> {
        guard let queryCountry = request.query[String.self, at: Params.country] else {
            throw Abort(HTTPStatus.notFound)
        }
        
        return Location.query(on: request).filter(\Location.country, .equal, queryCountry).all().flatMap { locations in
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
    
    private func sortedByCountryAscendingRequest(request: Request, locations: [Location])throws -> Future<LocationsResponse> {
        let all = sortedByCountryAscending(locations: locations)
        return Future.map(on: request) { return all }
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
