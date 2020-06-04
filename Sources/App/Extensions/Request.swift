import Vapor
import Fluent

struct HttpHeaders {
    var deviceID: UUID
    var version: String
    var platform: String
}

extension Request {
    func getAppHeaders() throws -> HttpHeaders {
        let deviceID = try getUUIDFromHeader()
        let appVersion = try getAppVersion()
        let appPlatform = try getAppPlatform()
        return HttpHeaders(deviceID: deviceID, version: appVersion, platform: appPlatform)
    }
    
    private func getUUIDFromHeader() throws -> UUID {
        guard let deviceIDString = self.http.headers["deviceID"].first, let deviceID = UUID(uuidString: deviceIDString) else { throw Abort.init(.badRequest, reason: "missing 'deviceID' in header") }
        return deviceID
    }
    
    private func getAppVersion() throws -> String {
        guard let version = self.http.headers["version"].first else { throw Abort.init(.badRequest, reason: "missing 'version' in header") }
        return version
    }
    
    private func getAppPlatform() throws -> String {
        guard let platform = self.http.headers["platform"].first else { throw Abort.init(.badRequest, reason: "missing 'platform' in header") }
        return platform
    }
}
