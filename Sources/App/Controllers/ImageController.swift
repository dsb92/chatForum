import Vapor
import Fluent

struct ImageResponse: Codable {
    var id: UUID
}

struct FileContent: Content {
    var file: File
}

extension ImageResponse: Content { }

final class ImageController: RouteCollection {
    // Register all 'users' routes
    func boot(router: Router) throws {
        let images = router.grouped("upload/image")
        
        // Regiser each handler
        images.post(use: postImage)
        images.get(UUID.parameter, use: getImage)
    }
    
    // POST IMAGE
    func postImage(_ request: Request)throws -> Future<ImageResponse> {
//        return image.create(on: request).map(to: ImageResponse.self) { i in
//            print(i.imageRaw)
//            return ImageResponse(id: i.id!)
//        }
        
        let directory = DirectoryConfig.detect()
        let workPath = directory.workDir
        
        let id = UUID()
        let name = id.uuidString + ".png"
        let imageFolder = "Public/images"
        let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
        
        return try request.content.decode(FileContent.self).flatMap { payload in
            do {
                try payload.file.data.write(to: saveURL)
                return Future.map(on: request) { ImageResponse(id: id) }
            } catch {
                throw Abort(.internalServerError, reason: "Unable to write multipart form data to file. Underlying error \(error)")
            }
        }
    }
    
    // GET IMAGE
    func getImage(_ request: Request)throws -> Future<Response> {
        let directory = DirectoryConfig.detect()
        let workPath = directory.workDir
        
        let id = try request.parameters.next(UUID.self)
        
        let name = id.uuidString + ".png"
        let imageFolder = "Public/images"
        let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
        do {
            let data = try Data(contentsOf: saveURL)
            return Future.map(on: request) { request.response(data, as: MediaType.jpeg) }
        } catch {
            return Future.map(on: request) { request.response("image not available") }
        }
//        return try request.content.decode(Image.self).map { payload in
//
//        }
    }
}
