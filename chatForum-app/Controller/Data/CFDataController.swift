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
    
    typealias GetPostsCallback = ([CFPost]) -> ()
    typealias PostPostCallback = (CFPost) -> ()
    typealias GetCommentsCallback = ([CFComment]) -> ()
    
    let dateFormat: String = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    struct Urls {
        static let baseUrl = "https://chatforum-production.vapor.cloud/"
        static let posts = CFDataController.Urls.baseUrl.grouped("posts")
    }
    
    private override init() {
        super.init()
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
    
    func postPost(text: String, updatedAt: String, callback: @escaping PostPostCallback) {
        let parameters: [String: Any] = [
            "text": text,
            "updatedAt": updatedAt
        ]
        Alamofire.request(Urls.posts, method: .post, parameters: parameters, encoding: JSONEncoding.default)
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
}
