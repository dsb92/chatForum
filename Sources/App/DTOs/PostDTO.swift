import Vapor

struct PostDTO: Content {
    var text: String
    var updatedAt: String
    var imageIds: [UUID]?
    var coordinate2D: Coordinate2DPosition?
}
