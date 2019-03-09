//
//  CFHomeVC.swift
//  ChatForum
//
//  Created by David Buhauer on 09/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit

class CFHomeVC: CFBaseVC {
    @IBOutlet weak var forumTableView: CFForumTableView!
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.forumTableView.addSubview(refreshControl)
        
        self.refreshData()
    }
    
    @objc func refreshData() {
        self.dataCon.getPosts { (posts) in
            self.forumTableView.posts = posts
            
            self.refreshControl.endRefreshing()
        }
    }
}
