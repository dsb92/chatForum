import Vapor
import Fluent

final class ImageController: RouteCollection, FileManageable {
    var fileRequester: FileRequester!
    
    func boot(router: Router) throws {
        fileRequester = FileRequester()
        
        let images = router.grouped("upload/image")
        
        images.post(use: postImage)
    }
    
    // POST IMAGE
    func postImage(request: Request) throws -> Future<FileResponse> {
        return try fileRequester.postFile(with: request, ext: .png, path: .images)
    }
}
