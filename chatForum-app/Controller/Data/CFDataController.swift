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
    
    typealias GetPostsCallback = ([CFPost]) -> Void
    
    private override init() {
        super.init()
    }
    
    func getPosts(_ callback: @escaping GetPostsCallback) {
        Alamofire.request("https://chatforum-production.vapor.cloud/posts", method: .get)
            .responseJSON { response in
                
                if let posts = response.result.value as! NSArray as? [CFPost] {
                    callback(posts)
                }
        }
    }
}
