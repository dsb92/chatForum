import Vapor
import Fluent

final class VideoController: RouteCollection, FileManageable {
    var fileRequester: FileRequester!
    
    func boot(router: Router) throws {
        fileRequester = FileRequester()
        
        let videos = router.grouped("upload/video")
        
        videos.post(use: postVideo)
    }
    
    // POST VIDEO
    func postVideo(_ request: Request)throws -> Future<FileResponse> {
        return try fileRequester.postFile(with: request, ext: .mp4, path: .videos)
    }
}
