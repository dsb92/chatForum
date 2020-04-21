import Vapor
import Fluent

final class SettingsController: RouteCollection {
    // Register all 'users' routes
    func boot(router: Router) throws {
        let colors = router.grouped("settings")
        
        // Regiser each handler
        colors.get(use: getSettings)
    }
    
    // GET SETTINGS
    func getSettings(_ request: Request)throws -> Future<SettingsResponse> {
        let val = Color.query(on: request).all()
        return val.flatMap { colors in
            let all = SettingsResponse(colors: colors)
            return Future.map(on: request) { return all }
        }
    }
    
    func synchronizeLocalData() {
        
    }
}
