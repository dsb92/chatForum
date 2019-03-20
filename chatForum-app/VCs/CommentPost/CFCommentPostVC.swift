//
//  CFCommentPostVC.swift
//  chatForum-app
//
//  Created by David Buhauer on 20/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit

class CFCommentPostVC: CFBaseVC {
    @IBOutlet weak var commentsTableView: CFCommentTableView!
    
    private let refreshControl = UIRefreshControl()
    
    private var post: CFPost?
    
    init(post: CFPost) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        self.commentsTableView.addSubview(self.refreshControl)
        self.commentsTableView.post = post
        
        self.refreshData()
    }
    
    @objc func refreshData() {
        guard let post = self.post else { return }
        guard let postId = post.id else { return }
        
        self.dataCon.getComments(from: postId) { (comments) in
            self.commentsTableView.comments = comments
            self.commentsTableView.reloadData()
            
            self.refreshControl.endRefreshing()
        }
    }
}
