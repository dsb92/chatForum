import Vapor
import Fluent

struct FileResponse: Codable {
    var id: UUID
}

struct FileContent: Content {
    var file: File
    var id: UUID?
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
    func writeToFile(nsfw: NSFWContentProvider, with request: Request, ext: Extension, path: Folder, file: File, id: UUID) throws -> Future<NSFWFileResponse> {
        return try request.content.decode(FileContent.self).flatMap(to: NSFWFileResponse.self) { content in
            return try nsfw.checkNudity(on: request, file: content.file).flatMap(to: NSFWFileResponse.self) { nsfw in
                if nsfw.error != nil || nsfw.detectedNudity {
                    return Future.map(on: request) {
                        return NSFWFileResponse(id: nil, nsfw: nsfw)
                    }
                } else {
                    return try self.writeToFile(with: request, ext: ext, path: path, file: file, id: id).flatMap(to: NSFWFileResponse.self) { fileResponse in
                        return Future.map(on: request) {
                            return NSFWFileResponse(id: fileResponse.id, nsfw: nsfw)
                        }
                    }
                }
            }
        }
    }
    
    func deleteFile(with request: Request, ext: Extension, path: Folder, id: UUID) throws -> Future<HTTPStatus>{
        let saveURL = filePathURL(ext: ext, path: path, id: id)
        do {
            try FileManager.default.removeItem(at: saveURL)
            return Future.map(on: request) { .noContent }
        } catch {
            throw Abort(.internalServerError, reason: "Unable to delete file. Underlying error \(error)")
        }
    }
    
    private func writeToFile(with request: Request, ext: Extension, path: Folder, file: File, id: UUID) throws -> Future<FileResponse> {
        let saveURL = filePathURL(ext: ext, path: path, id: id)
        do {
            try file.data.write(to: saveURL)
            return Future.map(on: request) { FileResponse(id: id) }
        } catch {
            throw Abort(.internalServerError, reason: "Unable to write multipart form data to file. Underlying error \(error)")
        }
    }
    
    private func filePathURL(ext: Extension, path: Folder, id: UUID) -> URL {
        let directory = DirectoryConfig.detect()
        let workPath = directory.workDir
        
        let name = id.uuidString + "." + ext.rawValue
        let imageFolder = "Public/" + path.rawValue
        return URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
    }
}

protocol FileManageable {
    var fileRequester: FileRequester! { get }
}

extension FileResponse: Content { }
