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
//        static let baseUrl = "https://chatforum-production.vapor.cloud/"
        static let baseUrl = "http://localhost:8080/"
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
    func uploadImage(callback: @escaping PostUploadImage) {
        let url = "http://localhost:8080/upload/image"
        
        guard let image = UIImage(named: "IMG_0321"), let imageData: Data = image.pngData() else { return }
        
        let headers = [
            "Content-Type": "application/form-data"
        ]
        
        let parameters = [
            "imageRaw": imageData
        ]
        
        Alamofire.upload(multipartFormData:{ multipartFormData in
            multipartFormData.append(imageData, withName: "imageRaw")},
                         usingThreshold:UInt64.init(),
                         to: url,
                         method:.post,
                         headers:headers,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    debugPrint(response)
                                    if let jsonDict = response.result.value as? NSDictionary, let imageId: String = jsonDict.object(forKey: "id") as? String {
                                        if let uuid = UUID(uuidString: imageId) {
                                            callback(uuid)
                                        }
                                    }
                                }
                            case .failure(let encodingError):
                                print(encodingError)
                            }
        })
    }
}
