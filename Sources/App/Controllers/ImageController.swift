import Vapor
import Fluent

struct ImageResponse: Codable {
    var id: UUID
}

extension ImageResponse: Content { }

final class ImageController: RouteCollection {
    // Register all 'users' routes
    func boot(router: Router) throws {
        let images = router.grouped("upload/image")
        
        // Regiser each handler
        images.post(Image.self, use: postImage)
        images.get(Image.parameter, use: getImage)
    }
    
    // POST IMAGE
    func postImage(_ request: Request, _ image: Image)throws -> Future<ImageResponse> {
        return image.create(on: request).map(to: ImageResponse.self) { i in
            print(i.imageRaw)
            return ImageResponse(id: i.id!)
        }
    }
    
    // GET IMAGE
    func getImage(_ request: Request)throws -> Future<Image> {
        return try request.parameters.next(Image.self)
    }
}
