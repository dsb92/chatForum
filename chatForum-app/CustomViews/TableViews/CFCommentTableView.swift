//
//  CFCommentTableView.swift
//  chatForum-app
//
//  Created by David Buhauer on 20/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit

protocol CFCommentTableViewDelegate: class {
    func didLikeComment(_ comment: CFComment, liked: Bool, sender: CFCommentTableView)
    func didDislikeComment(_ comment: CFComment, disliked: Bool, sender: CFCommentTableView)
}

class CFCommentTableView: CFBaseTableView {

    var post: CFPost?
    var comments = [CFComment]()
    
    weak var commentTableViewDelegate: CFCommentTableViewDelegate?
    
    override func registerCells() {
        self.registerReusableCell(CFForumCell.self)
        self.registerReusableHeaderFooterView(CFCommentsTableHeaderView.self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CFForumCell = tableView.dequeueReusableCell(indexPath: indexPath) as CFForumCell
        
        let comment = self.comments[indexPath.row]
        cell.forumTextLabel.text = comment.comment
        cell.forumDateLabel.text = comment.timeAgo()
        cell.backgroundColor = UIColor.clear
        cell.backgroundView = UIView()
        cell.forumCommentView.isHidden = true
        cell.seperator.isHidden = true
        
        cell.forumNumberOfLikesLabel.isHidden = comment.numberOfLikes == nil || comment.numberOfLikes == 0
        if let numberOfLikes = comment.numberOfLikes {
            cell.forumNumberOfLikesLabel.text = "\(numberOfLikes)"
        }
        
        cell.forumNumberOfDislikesLabel.isHidden = comment.numberOfDislikes == nil || comment.numberOfDislikes == 0
        if let numberOfDislikes = comment.numberOfDislikes {
            cell.forumNumberOfDislikesLabel.text = "\(numberOfDislikes)"
        }
        
        cell.forumLikeButton.isSelected = CFDataController.shared.liked.first { $0 == comment.id } != nil
        cell.forumDislikeButton.isSelected = CFDataController.shared.disliked.first { $0 == comment.id } != nil
        
        cell.delegate = self
        cell.comment = comment
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: CFCommentsTableHeaderView.self))! as! CFCommentsTableHeaderView
        
        header.forumTextLabel.text = self.post?.text
        header.forumDateLabel.text = self.post?.timeAgo()
        header.containerView.backgroundColor = UIColor(hexString: self.post?.backgroundColorHex ?? "")
        
        if let numberOfComments = self.post?.numberOfComments {
            header.forumCommentView.isHidden = numberOfComments == 0
            header.forumNumberOfCommentsLabel.text = "\(numberOfComments)"
        }
        
        return header
    }
}

extension CFCommentTableView: CFForumCellDelegate {
    func didTapLikeButton(liked: Bool, sender: CFForumCell) {
        guard let comment = sender.comment else { return }
        commentTableViewDelegate?.didLikeComment(comment, liked: liked, sender: self)
    }
    
    func didTapDislikeButton(disliked: Bool, sender: CFForumCell) {
        guard let comment = sender.comment else { return }
        commentTableViewDelegate?.didDislikeComment(comment, disliked: disliked, sender: self)
    }
}
