import Vapor
import Fluent

extension Request {
    func getUUIDFromHeader() throws -> UUID {
        guard let deviceIDString = self.http.headers["deviceID"].first, let deviceID = UUID(uuidString: deviceIDString) else { throw Abort.init(.badRequest) }
        return deviceID
    }
}
