import Vapor
import Fluent
import Pagination

protocol BlockManageable {
    func removingBlocked<T>(blocked: [T], request: Request) -> Future<[T]> where T: PostgreModel
    func removingBlockedPaginated<T>(blocked: [T], request: Request) throws -> Future<Paginated<T>> where T: PostgreModel & Paginatable
}

extension BlockManageable {
    // Filter out by devices that are blocked and not supposed to be seen by user with passed deviceID from header
    func removingBlocked<T>(blocked: [T], request: Request) -> Future<[T]> where T: PostgreModel {
        return T.query(on: request).all().flatMap(to: [T].self) { all in
            return self.removingBlocked(blocked: blocked, all: all, request: request)
        }
    }
    
    func removingBlockedPaginated<T>(blocked: [T], request: Request) throws -> Future<Paginated<T>> where T: PostgreModel & Paginatable {
        return try T.query(on: request).paginate(for: request).flatMap(to: Paginated<T>.self) { all in
            return self.removingBlocked(blocked: blocked, all: all.data, request: request).flatMap { data in
                return Future.map(on: request) { Paginated(page: all.page, data: data) }
            }
        }
    }
    
    private func removingBlocked<T>(blocked: [T], all: [T], request: Request) -> Future<[T]> where T: PostgreModel  {
        var match = all
        for blockedPost in blocked {
            match.removeAll(where: { $0.id == blockedPost.id })
        }
        
        return Future.map(on: request) { match }
    }
}

extension PostgreModel where Self: Identifiable {
    static func queryBlocked(on request: Request, deviceID: UUID) -> QueryBuilder<Database, Self> {
        return self.query(on: request).join(\BlockedDevice.deviceID, to: \Self.deviceID).filter(\BlockedDevice.blockedDeviceID == deviceID)
    }
}
