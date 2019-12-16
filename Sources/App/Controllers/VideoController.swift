import Vapor
import Fluent

final class VideoController: RouteCollection, FileManageable, NSFWContentManagable {
    var nsfwContentProvider: NSFWContentProvider!
    var fileRequester: FileRequester!
    
    func boot(router: Router) throws {
        fileRequester = FileRequester()
        nsfwContentProvider = SightEngineProvider()
        
        let videos = router.grouped("upload/video")
        
        videos.post(use: postVideo)
    }
    
    // POST VIDEO
    func postVideo(_ request: Request)throws -> Future<NSFWFileResponse> {
        return try request.content.decode(FileContent.self).flatMap(to: NSFWFileResponse.self) { content in
            return try self.fileRequester.writeToFile(nsfw: self.nsfwContentProvider, with: request, ext: .mp4, path: .videos, file: content.file, id: content.id ?? UUID())
        }
    }
}
