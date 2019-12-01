import Vapor

struct SightEngineFile: Codable {
    let media: File
}
extension SightEngineFile: Content {}
