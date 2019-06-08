//
//  CFDataController.swift
//  ChatForum
//
//  Created by David Buhauer on 09/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import AlamofireImage
import AlamofireActivityLogger
import SwiftyJSON

enum CFMimeType: String {
    case imageJpeg = "image/jpeg"
    case imagePng = "image/png"
    case videoMp4 = "video/mp4"
}
class CFDataController: NSObject {
    static let shared = CFDataController()
    
    typealias GetSettingsCallback = (CFSettingsParser) -> ()
    typealias GetPostsCallback = ([CFPost]) -> ()
    typealias PostPostCallback = (CFPost) -> ()
    typealias GetCommentsCallback = ([CFComment]) -> ()
    typealias PostCommentCallback = (CFComment) -> ()
    typealias PostUploadImage = (UUID) -> ()
    typealias LikeCallback = (Int) -> ()
    typealias DislikeCallback = (Int) -> ()
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = self.dateFormat
        return df
    }()
    let dateFormat: String = "yyyy-MM-dd'T'HH:mm:ssZ"
    var colors: [UIColor] = [UIColor]()
    
    private var _liked: [String] = [String]()
    var liked: [String] {
        get {
            return _liked
        }
        set {
            _liked = newValue
            saveLocalLikes()
        }
    }
    private var _disliked: [String] = [String]()
    var disliked: [String] {
        get {
            return _disliked
        }
        set {
            _disliked = newValue
            saveLocalDislikes()
        }
    }
    
    struct Urls {
        static let baseUrl = "http://chatforum-app.vapor.red:8000/"
//        static let baseUrl = "http://localhost:8080/"
        static let imageUpload = CFDataController.Urls.baseUrl.grouped("upload/image")
        static let imageUrl = CFDataController.Urls.baseUrl.grouped("images")
        static let videoUpload = CFDataController.Urls.baseUrl.grouped("upload/video")
        static let videoUrl = CFDataController.Urls.baseUrl.grouped("videos")
        static let settings = CFDataController.Urls.baseUrl.grouped("settings")
        static let posts = CFDataController.Urls.baseUrl.grouped("posts")
        static let comments = CFDataController.Urls.baseUrl.grouped("comments")
    }
    
    private override init() {
        super.init()
        
        getSettings { (parser) in
            parser.colors?.forEach({ (cfColor) in
                self.colors.append(UIColor(hexString: cfColor.hexString ?? ""))
            })
        }
        
        _liked = loadLocalLikes()
        disliked = loadLocalDislikes()
    }
    
    // MARK: - Settings
    func getSettings(_ callback: @escaping GetSettingsCallback) {
        makeRequest(urlString: Urls.settings, httpMethod: HTTPMethod.get) { (parser: CFSettingsParser) in
            callback(parser)
        }
    }
    
    // MARK: - Posts
    func getPosts(_ callback: @escaping GetPostsCallback) {
        makeRequest(urlString: Urls.posts, httpMethod: .get) { (parser: CFPostParser) in
            guard let posts = parser.posts else { return }
            callback(posts)
        }
    }
    
    func postPost(_ post: CFPost, callback: @escaping PostPostCallback) {
        do {
            let data = try JSON(data: JSONEncoder().encode(post))
            makeRequest(urlString: Urls.posts, httpMethod: .post, parameters: data.dictionaryObject) { (responsePost: CFPost) in
                callback(responsePost)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Comments
    func getComments(from postId: String, callback: @escaping GetCommentsCallback) {
        makeRequest(urlString: Urls.posts + "/\(postId)/comments", httpMethod: .get) { (parser: CFCommentsParser) in
            guard let comments = parser.comments else { return }
            callback(comments)
        }
    }
    
    func postComment(_ comment: CFComment, callback: @escaping PostCommentCallback) {
        do {
            let data = try JSON(data: JSONEncoder().encode(comment))
            makeRequest(urlString: Urls.comments, httpMethod: .post, parameters: data.dictionaryObject) { (comment: CFComment) in
                callback(comment)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Likes & Dislikes
    func postLikePost(postID: UUID, callback: @escaping LikeCallback) {
        makeRequest(urlString: Urls.posts + "/\(postID.uuidString)/like", httpMethod: .post) { (likes: CFLike) in
            callback(likes.numberOfLikes ?? 0)
        }
    }
    
    func deleteLikePost(postID: UUID, callback: @escaping LikeCallback) {
        makeRequest(urlString: Urls.posts + "/\(postID.uuidString)/like", httpMethod: .delete) { (likes: CFLike) in
            callback(likes.numberOfLikes ?? 0)
        }
    }
    
    func postLikeComment(commentID: UUID, callback: @escaping LikeCallback) {
        makeRequest(urlString: Urls.comments + "/\(commentID.uuidString)/like", httpMethod: .post) { (likes: CFLike) in
            callback(likes.numberOfLikes ?? 0)
        }
    }
    
    func deleteLikeComment(commentID: UUID, callback: @escaping LikeCallback) {
        makeRequest(urlString: Urls.comments + "/\(commentID.uuidString)/like", httpMethod: .delete) { (likes: CFLike) in
            callback(likes.numberOfLikes ?? 0)
        }
    }
    
    func postDislikePost(postID: UUID, callback: @escaping DislikeCallback) {
        makeRequest(urlString: Urls.posts + "/\(postID.uuidString)/dislike", httpMethod: .post) { (likes: CFDislike) in
            callback(likes.numberOfDislikes ?? 0)
        }
    }
    
    func deleteDislikePost(postID: UUID, callback: @escaping DislikeCallback) {
        makeRequest(urlString: Urls.posts + "/\(postID.uuidString)/dislike", httpMethod: .delete) { (likes: CFDislike) in
            callback(likes.numberOfDislikes ?? 0)
        }
    }
    
    func postDislikeComment(commentID: UUID, callback: @escaping DislikeCallback) {
        makeRequest(urlString: Urls.comments + "/\(commentID.uuidString)/dislike", httpMethod: .post) { (likes: CFDislike) in
            callback(likes.numberOfDislikes ?? 0)
        }
    }
    
    func deleteDislikeComment(commentID: UUID, callback: @escaping DislikeCallback) {
        makeRequest(urlString: Urls.comments + "/\(commentID.uuidString)/dislike", httpMethod: .delete) { (likes: CFDislike) in
            callback(likes.numberOfDislikes ?? 0)
        }
    }
    
    // MARK: - Persist
    func saveLocalLikes() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(liked) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedLikes")
        }
    }
    
    func loadLocalLikes() -> [String] {
        let defaults = UserDefaults.standard
        if let savedLikes = defaults.object(forKey: "SavedLikes") as? Data {
            let decoder = JSONDecoder()
            if let loadedLikes = try? decoder.decode([String].self, from: savedLikes) {
                print(loadedLikes)
                return loadedLikes
            }
        }
        
        return [String]()
    }
    
    func saveLocalDislikes() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(disliked) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedDislikes")
        }
    }
    
    func loadLocalDislikes() -> [String] {
        let defaults = UserDefaults.standard
        if let savedDislikes = defaults.object(forKey: "SavedDislikes") as? Data {
            let decoder = JSONDecoder()
            if let loadedDislikes = try? decoder.decode([String].self, from: savedDislikes) {
                print(loadedDislikes)
                return loadedDislikes
            }
        }
        
        return [String]()
    }
    
    // MARK: - Image upload
    func uploadImage(_ image: UIImage, callback: @escaping PostUploadImage) {
//        guard let image = UIImage(named: "IMG_0321"), let imageData: Data = image.pngData() else { return }
        let (resizeImage, imageData) = image.resized(with: 540, compressionQuality: 0.95)
        guard let imageRaw = imageData else { return }
        uploadRequest(urlString: Urls.imageUpload, data: imageRaw, name: "file", fileName: "testImage.jpeg", mimeType: .imageJpeg, completion: callback)
    }
    
    func getImageUrl(from imageId: String) -> URL? {
        return URL(string: Urls.imageUrl + "/" + imageId + ".png")
    }
    
    // MARK: - Video upload
    func uploadVideo() {
        guard let videoUrl = Bundle.main.path(forResource: "video", ofType: "mp4") else { debugPrint("video not found"); return }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: videoUrl), options: .mappedIfSafe)
            
            uploadRequest(urlString: Urls.videoUpload, data: data, name: "file", fileName: "video.mp4", mimeType: .videoMp4, completion: { _ in  })
        } catch  {
            debugPrint(error.localizedDescription)
        }
    }
    
    func getVideo() {
        guard let url = getVideoUrl(from: "D4C0CE6A-D64D-4F74-9545-021FA8676F4F") else { debugPrint("Not an url"); return }
        
        Alamofire.request(url, method: .get)
            .validate()
            .responseData { data in
                print(data)
        }
    }
    
    func getVideoUrl(from videoId: String) -> URL? {
        return URL(string: Urls.videoUrl + "/" + videoId + ".mp4")
    }
    
    private func uploadRequest(urlString: String, data: Data, name: String, fileName: String, mimeType: CFMimeType, completion: @escaping (UUID) -> ()) {
        let headers: HTTPHeaders? = getAuthorization()
        
        Alamofire.upload( multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: name, fileName: fileName, mimeType: mimeType.rawValue)}, to: urlString, headers: headers, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        print("response.result :\(String(describing: response.result.value))")
                        
                        if let responseDic = response.result.value as? [String: Any] {
                            if let uuidString = responseDic["id"] as? String, let uuid = UUID(uuidString: uuidString) {
                                print(uuid)
                                completion(uuid)
                            }
                        } else {
                            print(response)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    private func makeRequest<T: Codable>(urlString: String, httpMethod: HTTPMethod, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, authorizationHeader: HTTPHeaders? = nil, completion: @escaping (T) -> ()) {
        
        let headers = authorizationHeader ?? getAuthorization()
        
        Alamofire.request(urlString, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers)
            .validate()
            .log()
            .response { response in
                
            guard response.error == nil else {
                print("error calling on \(urlString)")
                return
            }
            
            guard let data = response.data else {
                print("there was an error with the data")
                return
            }
            
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(model)
            } catch let jsonErr {
                print("failed to decode, \(jsonErr)")
            }
        }
    }
    
    private func getSecretJSON() -> JSON? {
        let location = "secret"
        let fileType = "json"
        if let path = Bundle.main.path(forResource: location, ofType: fileType) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                return try JSON(data: data)
            } catch let error {
                print(error.localizedDescription)
            }}
        
        return nil
    }
    
    private func getAuthorization() -> HTTPHeaders? {
        guard let secretJSON = getSecretJSON() else { return nil }
        
        let username = secretJSON["BASIC_AUTH_USER"].stringValue
        let password = secretJSON["BASIC_AUTH_PASS"].stringValue
        if let auth = Request.authorizationHeader(user: username, password: password) {
            let key = auth.0
            let value = auth.1
            
            return [key: value, "Content-Type": "application/json"]
        }
        
        return nil
    }
}
