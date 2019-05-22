import Vapor

final class SecretMiddleware: Middleware {
    
    let secret: String
    
    init(secret: String) {
        self.secret = secret
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        
        guard let bearerAuthorization = request.http.headers.bearerAuthorization else {
            throw Abort(.unauthorized, reason: "Missing token")
        }
        
        guard bearerAuthorization.token == secret else {
            throw Abort(.unauthorized, reason: "Wrong token")
        }
        
        return try next.respond(to: request)
    }
}

extension SecretMiddleware: ServiceType {
    
    static func makeService(for worker: Container) throws -> SecretMiddleware {
        
        let secret: String
        guard let envSecret = Environment.get("SECRET") else {
            let reason = "No SECRET set on environment."
            throw Abort(.internalServerError, reason: reason)
        }
        secret = envSecret
        return SecretMiddleware(secret: secret)
    }
}
