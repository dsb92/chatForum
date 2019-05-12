//
//  CFForumTableView.swift
//  ChatForum
//
//  Created by David Buhauer on 09/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit

protocol CFForumTableViewDelegate: class {
    func didSelectPost(_ post: CFPost, sender: CFForumTableView)
}

class CFForumTableView: CFBaseTableView {
    
    var posts = [CFPost]()
    
    weak var forumTableViewDelegate: CFForumTableViewDelegate?
    
    override func registerCells() {
        self.registerReusableCell(CFForumCell.self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CFForumCell = tableView.dequeueReusableCell(indexPath: indexPath) as CFForumCell
        
        let post = self.posts[indexPath.row]
        cell.forumTextLabel.text = post.text
        cell.forumDateLabel.text = post.timeAgo()
        
        if let numberOfComments = post.numberOfComments {
            cell.forumCommentView.isHidden = numberOfComments == 0
            cell.forumNumberOfCommentsLabel.text = "\(numberOfComments)"
        }

        cell.backgroundColor = UIColor(hexString: post.backgroundColorHex ?? "")
        cell.forumImageView.af_setImage(withURL: URL(string: "http://localhost:8080/upload/image/89C2C13D-D8B6-4B69-AD10-3E3B7955E6C2")!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        self.forumTableViewDelegate?.didSelectPost(self.posts[indexPath.row], sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
