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
    func postFile(with request: Request, ext: Extension, path: Folder) throws -> Future<FileResponse> {
        let directory = DirectoryConfig.detect()
        let workPath = directory.workDir
        
        let id = UUID()
        let name = id.uuidString + "." + ext.rawValue
        let imageFolder = "Public/" + path.rawValue
        let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
        
        return try request.content.decode(FileContent.self).flatMap { payload in
            do {
                try payload.file.data.write(to: saveURL)
                return Future.map(on: request) { FileResponse(id: id) }
            } catch {
                throw Abort(.internalServerError, reason: "Unable to write multipart form data to file. Underlying error \(error)")
            }
        }
    }

// This is no longer needed since we serve files with FileMiddleware.
//    func getFile(with request: Request, ext: Extension, path: Folder, asMediaType mediaType: MediaType) throws -> Future<Response> {
//        let directory = DirectoryConfig.detect()
//        let workPath = directory.workDir
//
//        let id = try request.parameters.next(UUID.self)
//
//        let name = id.uuidString + "." + ext.rawValue
//        let imageFolder = "Public/" + path.rawValue
//        let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
//        do {
//            let data = try Data(contentsOf: saveURL)
//            return Future.map(on: request) { request.response(data, as: mediaType) }
//        } catch {
//            debugPrint(error.localizedDescription)
//            return Future.map(on: request) { request.response("file not available") }
//        }
//    }
}

protocol FileManageable {
    var fileRequester: FileRequester! { get }
    func postFile(with request: Request, ext: Extension, path: Folder) throws -> Future<FileResponse>
//    func getFile(with request: Request, ext: Extension, path: Folder, asMediaType mediaType: MediaType) throws -> Future<Response>
}

extension FileManageable {
    func postFile(with request: Request, ext: Extension, path: Folder) throws -> Future<FileResponse> {
        return try fileRequester.postFile(with: request, ext: ext, path: path)
    }
    
//    func getFile(with request: Request, ext: Extension, path: Folder, asMediaType mediaType: MediaType) throws -> Future<Response> {
//        return try fileRequester.getFile(with: request, ext: ext, path: path, asMediaType: mediaType)
//    }
}

extension FileResponse: Content { }
