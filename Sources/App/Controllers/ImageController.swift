import Vapor
import Fluent

final class ImageController: RouteCollection, FileManageable, NSFWContentManagable {
    var nsfwContentProvider: NSFWContentProvider!
    
    var fileRequester: FileRequester!
    
    func boot(router: Router) throws {
        fileRequester = FileRequester()
        nsfwContentProvider = SightEngineProvider()
        
        let images = router.grouped("upload/image")
        
        images.post(use: postUploadImage)
        images.put(use: putUploadImage)
        images.delete(UUID.parameter, use: deleteImage)
    }
    
    // POST IMAGE
    func postUploadImage(request: Request) throws -> Future<NSFWFileResponse> {
        return try request.content.decode(FileContent.self).flatMap(to: NSFWFileResponse.self) { content in
            return try self.fileRequester.writeToFile(nsfw: self.nsfwContentProvider, with: request, ext: .png, path: .images, file: content.file, id: UUID())
        }
    }
    
    // PUT IMAGE
    func putUploadImage(request: Request) throws -> Future<NSFWFileResponse> {
        return try request.content.decode(FileContent.self).flatMap(to: NSFWFileResponse.self) { content in
            guard let id = content.id else {
                throw Abort(.badRequest, reason: "Missing image id")
            }
            return try self.fileRequester.writeToFile(nsfw: self.nsfwContentProvider, with: request, ext: .png, path: .images, file: content.file, id: id)
        }
    }
    
    // DELETE IMAGE
    func deleteImage(request: Request) throws -> Future<HTTPStatus> {
        guard let firstParameterValue = request.parameters.values.first?.value, let id = UUID(uuidString: firstParameterValue) else {
            throw Abort(.badRequest)
        }
        return try self.fileRequester.deleteFile(with: request, ext: .png, path: .images, id: id).transform(to: .noContent)
    }
}
