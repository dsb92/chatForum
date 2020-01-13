import Vapor

final class VersionMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        guard let version = request.http.headers["version"].first else {
            //throw Abort(.badRequest, reason: "Missing version")
            return try next.respond(to: request)
        }
        
        guard let platform = request.http.headers["platform"].first else {
            //throw Abort(.badRequest, reason: "Missing platform")
            return try next.respond(to: request)
        }
        
        return AllowedDevice.query(on: request).group(.or) {
            $0.filter(\AllowedDevice.platform, .equal, platform).filter(\AllowedDevice.version, .equal, version)
        }.first().flatMap(to: Response.self) { allowedDevice in
            guard let allowedDevice = allowedDevice else {
                throw Abort(.badRequest, reason: "Version \(version) and platform \(platform) does not exist")
            }
            
            guard let appVersion = Double(version) else {
                throw Abort(.badRequest, reason: "Version is in unknown format.")
            }
            
            guard let apiVersion = Double(allowedDevice.version) else {
                throw Abort(.badRequest, reason: "Api version is in unknown format.")
            }
            
            if allowedDevice.platform == platform && apiVersion > appVersion {
                throw Abort(.conflict, reason: "Platform \(platform) has a newer version")
            }
            
            return try next.respond(to: request)
        }
    }
}

extension VersionMiddleware: ServiceType {
    
    static func makeService(for worker: Container) throws -> VersionMiddleware {
        return VersionMiddleware()
    }
}
