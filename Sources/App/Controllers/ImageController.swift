import Vapor
import Fluent

final class ImageController: RouteCollection, FileManageable, NSFWContentManagable {
    var nsfwContentProvider: NSFWContentProvider!
    
    var fileRequester: FileRequester!
    
    func boot(router: Router) throws {
        fileRequester = FileRequester()
        nsfwContentProvider = SightEngineProvider()
        
        let images = router.grouped("upload/image")
        
        images.post(use: postImage)
    }
    
    // POST IMAGE
    func postImage(request: Request) throws -> Future<NSFWFileResponse> {
        return try request.content.decode(FileContent.self).flatMap(to: NSFWFileResponse.self) { content in
            return try self.fileRequester.postFile(nsfw: self.nsfwContentProvider, with: request, ext: .png, path: .images, file: content.file)
        }
    }
}
