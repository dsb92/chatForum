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

class CFDataController: NSObject {
    static let shared = CFDataController()
    
    typealias GetSettingsCallback = (CFSettingsParser) -> ()
    typealias GetPostsCallback = ([CFPost]) -> ()
    typealias PostPostCallback = (CFPost) -> ()
    typealias GetCommentsCallback = ([CFComment]) -> ()
    typealias PostCommentCallback = (CFComment) -> ()
    typealias PostUploadImage = (UUID) -> ()
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = self.dateFormat
        return df
    }()
    let dateFormat: String = "yyyy-MM-dd'T'HH:mm:ssZ"
    var colors: [UIColor] = [UIColor]()
    
    struct Urls {
        static let baseUrl = "https://chatforum-production.vapor.cloud/"
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
        
        uploadImage(UIImage(named: "IMG_0321")!) { id in

        }
        
//        getImage()
        
//        uploadVideo()
//        getVideo()
    }
    
    // MARK: - Settings
    func getSettings(_ callback: @escaping GetSettingsCallback) {
        Alamofire.request(Urls.settings, method: .get)
            .validate()
            .responseObject { (response: DataResponse<CFSettingsParser>) in
                
                if let parser = response.result.value {
                    callback(parser)
                }
        }
    }
    
    // MARK: - Posts
    func getPosts(_ callback: @escaping GetPostsCallback) {
        Alamofire.request(Urls.posts, method: .get)
            .validate()
            .responseObject { (response: DataResponse<CFPostsParser>) in
                
                if let parser = response.result.value, let posts = parser.posts {
                    callback(posts)
                }
        }
    }
    
    func postPost(_ post: CFPost, callback: @escaping PostPostCallback) {
        Alamofire.request(Urls.posts, method: .post, parameters: post.toDictionary(), encoding: JSONEncoding.default)
            .validate()
            .responseObject { (response: DataResponse<CFPost>) in
                
                if let parser = response.result.value {
                    callback(parser)
                }
        }
    }
    
    // MARK: - Comments
    func getComments(from postId: String, callback: @escaping GetCommentsCallback) {
        Alamofire.request(Urls.posts + "/\(postId)/comments", method: .get)
            .validate()
            .responseObject { (response: DataResponse<CFCommentsParser>) in
                
                if let parser = response.result.value, let comments = parser.comments {
                    callback(comments)
                }
        }
    }
    
    func postComment(_ comment: CFComment, callback: @escaping PostCommentCallback) {
        Alamofire.request(Urls.comments, method: .post, parameters: comment.toDictionary(), encoding: JSONEncoding.default)
            .validate()
            .responseObject { (response: DataResponse<CFComment>) in
                
                if let parser = response.result.value {
                    callback(parser)
                }
        }
    }
    
    // MARK: - Image upload
    func uploadImage(_ image: UIImage, callback: @escaping PostUploadImage) {
//        guard let image = UIImage(named: "IMG_0321"), let imageData: Data = image.pngData() else { return }
        guard let imageData: Data = image.pngData() else { return }
        let imageName = "testImage.png"
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "file",fileName: imageName, mimeType: "image/png") }, to:Urls.imageUpload) { (result) in
                switch result {
                    
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        print("response.result :\(String(describing: response.result.value))")
                        
                        if let responseDic = response.result.value as? [String: Any] {
                            if let imageId = responseDic["id"] as? String, let imageGuid = UUID(uuidString: imageId) {
                                callback(imageGuid)
                            }
                        }
                    }
                    
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
    }
    
    func getImageUrl(from imageId: String) -> URL? {
        return URL(string: Urls.imageUrl + "/" + imageId + ".png")
    }
    
    // MARK: - Video upload
    func uploadVideo() {
        let url = "http://localhost:8080/upload/video"
        
        guard let videoUrl = Bundle.main.path(forResource: "video", ofType: "mp4") else { debugPrint("video not found"); return }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: videoUrl), options: .mappedIfSafe)
            
            Alamofire.upload( multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "file", fileName: "video.mp4", mimeType: "video/mp4")
                
            }, to: url, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                        print("response.result :\(String(describing: response.result.value))")
                        
                        if let responseDic = response.result.value as? [String: Any] {
                            if let videoId = responseDic["id"] as? String, let videoGUID = UUID(uuidString: videoId) {
                                print(videoId)
                            }
                        } else {
                            print(response)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            })
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
}
