//
//  CFForumTableView.swift
//  ChatForum
//
//  Created by David Buhauer on 09/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit

class CFForumTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    let IDENTIFIER: String = "CFForumCell"
    
    var posts = [CFPost]()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.setup()
        self.registerCells()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
        self.registerCells()
    }
    
    func setup() {
        self.tableHeaderView = UIView()
        self.tableFooterView = UIView()
        
        self.dataSource = self
        self.delegate = self
        
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 100
    }
    
    func registerCells() {
        self.register(UINib(nibName: IDENTIFIER, bundle: nil), forCellReuseIdentifier: IDENTIFIER)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CFForumCell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER, for: indexPath) as? CFForumCell else { return UITableViewCell() }
        
        let post = self.posts[indexPath.row]
        cell.forumTextLabel.text = post.text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
