import Vapor
import Fluent

protocol LocationProvider {
    func getReverseGeocode(on request: Request, coordinate2D: Coordinate2DPosition)throws -> Future<Geolocation?>
}

protocol LocationManagable {
    var locationProvider: LocationProvider! { get }
}
