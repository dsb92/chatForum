import Vapor

struct NSFWFileResponse: Codable {
    let id: UUID?
    let nsfw: NSFWMediaResponse
}
extension NSFWFileResponse: Content {}
