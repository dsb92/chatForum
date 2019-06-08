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
    func didLikePost(_ post: CFPost, liked: Bool, sender: CFForumTableView)
    func didDislikePost(_ post: CFPost, disliked: Bool, sender: CFForumTableView)
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
        
        cell.forumCommentView.isHidden = post.numberOfComments == nil || post.numberOfComments == 0
        if let numberOfComments = post.numberOfComments {
            cell.forumNumberOfCommentsLabel.text = "\(numberOfComments)"
        }
        
        cell.forumNumberOfLikesLabel.isHidden = post.numberOfLikes == nil || post.numberOfLikes == 0
        if let numberOfLikes = post.numberOfLikes {
            cell.forumNumberOfLikesLabel.text = "\(numberOfLikes)"
        }
        
        cell.forumNumberOfDislikesLabel.isHidden = post.numberOfDislikes == nil || post.numberOfDislikes == 0
        if let numberOfDislikes = post.numberOfDislikes {
            cell.forumNumberOfDislikesLabel.text = "\(numberOfDislikes)"
        }
        
        cell.forumLikeButton.isSelected = CFDataController.shared.liked.first { $0 == post.id } != nil
        cell.forumDislikeButton.isSelected = CFDataController.shared.disliked.first { $0 == post.id } != nil

        cell.backgroundColor = UIColor(hexString: post.backgroundColorHex ?? "")
        
        if let imageId = post.imageIds?.first?.uuidString, let imageUrl = CFDataController.shared.getImageUrl(from: imageId) {
            cell.forumImageView.af_setImage(withURL: imageUrl)
        }
        
        cell.delegate = self
        cell.post = post
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

extension CFForumTableView: CFForumCellDelegate {
    func didTapLikeButton(liked: Bool, sender: CFForumCell) {
        guard let post = sender.post else { return }
        forumTableViewDelegate?.didLikePost(post, liked: liked, sender: self)
    }
    
    func didTapDislikeButton(disliked: Bool, sender: CFForumCell) {
        guard let post = sender.post else { return }
        forumTableViewDelegate?.didDislikePost(post, disliked: disliked, sender: self)
    }
    
 
}
