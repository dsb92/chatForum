import Vapor

struct NSFWMediaResponse: Codable {
    let detectedNudity: Bool
    let error: SightEngineError?
}
extension NSFWMediaResponse: Content {}
