import Vapor

final class SecretMiddleware: Middleware {
    
    let username: String
    let password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        
        // Basic auth OR bearer is OK.
        guard let _ = request.http.headers.bearerAuthorization else {
            guard let basicAuthorization = request.http.headers.basicAuthorization else {
                throw Abort(.unauthorized, reason: "Missing authorization")
            }
            
            guard basicAuthorization.username == username else {
                throw Abort(.unauthorized, reason: "Wrong username")
            }
            
            guard basicAuthorization.password == password else {
                throw Abort(.unauthorized, reason: "Wrong password")
            }
            
            return try next.respond(to: request)
        }
        
        return try next.respond(to: request)
    }
}

extension SecretMiddleware: ServiceType {
    
    static func makeService(for worker: Container) throws -> SecretMiddleware {
        
        let username: String
        let password: String
        guard let envAuthUser = Environment.get("BASIC_AUTH_USER") else {
            let reason = "No SECRET set on environment."
            throw Abort(.internalServerError, reason: reason)
        }
        guard let envAuthPass = Environment.get("BASIC_AUTH_PASS") else {
            let reason = "No SECRET set on environment."
            throw Abort(.internalServerError, reason: reason)
        }
        username = envAuthUser
        password = envAuthPass
        
        return SecretMiddleware(username: username, password: password)
    }
}
