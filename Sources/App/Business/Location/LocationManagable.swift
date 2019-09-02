import Vapor
import Fluent

protocol LocationProvider {
    func getReverseGeocode(on request: Request, coordinate2D: Coordinate2DPosition)throws -> Future<Geolocation?>
}

protocol LocationManagable {
    var locationProvider: LocationProvider! { get }
    func getLocationFromPostByCoordinate2D(request: Request, post: Post) throws -> Future<Location>
}

extension LocationManagable {
    func getLocationFromPostByCoordinate2D(request: Request, post: Post) throws -> Future<Location> {
        guard let coordinate2D = post.coordinate2D else {
            return Future.map(on: request) { throw Abort(HTTPStatus.badRequest) }
        }
        
        return try self.locationProvider.getReverseGeocode(on: request, coordinate2D: coordinate2D).flatMap { geolocation -> EventLoopFuture<Location> in
            guard let postID = post.id, let geo = geolocation, let country = geo.country else {
                return Future.map(on: request) { throw Abort(HTTPStatus.badRequest) }
            }
            
            let location = Location(postID: postID, country: country, flagURL: geo.flagURL, city: geo.city)
            
            return Location.query(on: request).filter(\Location.postID, .equal, postID).first().flatMap { fetchedLocation -> EventLoopFuture<Location> in
                guard let existingLocation = fetchedLocation else {
                    return Location.query(on: request).create(location)
                }
                
                existingLocation.postID = location.postID
                existingLocation.country = location.country
                existingLocation.city = location.city
                existingLocation.flagURL = location.flagURL
                
                return Location.query(on: request).update(existingLocation)
            }
        }
    }
}
