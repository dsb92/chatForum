import Vapor
import Fluent

struct FileResponse: Codable {
    var id: UUID
}

struct FileContent: Content {
    var file: File
}

enum Extension: String {
    case png = "png"
    case mp4 = "mp4"
}

enum Folder: String {
    case images = "images"
    case videos = "videos"
}

struct FileRequester {
    func postFile(nsfw: NSFWContentProvider, with request: Request, ext: Extension, path: Folder, file: File) throws -> Future<NSFWFileResponse> {
        return try request.content.decode(FileContent.self).flatMap(to: NSFWFileResponse.self) { content in
            return try nsfw.checkNudity(on: request, file: content.file).flatMap(to: NSFWFileResponse.self) { nsfw in
                if nsfw.error != nil || nsfw.detectedNudity {
                    return Future.map(on: request) {
                        return NSFWFileResponse(id: nil, nsfw: nsfw)
                    }
                } else {
                    return try self.postFile(with: request, ext: ext, path: path, file: file).flatMap(to: NSFWFileResponse.self) { fileResponse in
                        return Future.map(on: request) {
                            return NSFWFileResponse(id: fileResponse.id, nsfw: nsfw)
                        }
                    }
                }
            }
        }
    }
    
    private func postFile(with request: Request, ext: Extension, path: Folder, file: File) throws -> Future<FileResponse> {
        let directory = DirectoryConfig.detect()
        let workPath = directory.workDir
        
        let id = UUID()
        let name = id.uuidString + "." + ext.rawValue
        let imageFolder = "Public/" + path.rawValue
        let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
        
        do {
            try file.data.write(to: saveURL)
            return Future.map(on: request) { FileResponse(id: id) }
        } catch {
            throw Abort(.internalServerError, reason: "Unable to write multipart form data to file. Underlying error \(error)")
        }
    }
}

protocol FileManageable {
    var fileRequester: FileRequester! { get }
}

extension FileResponse: Content { }
