//
//  CFForumCell.swift
//  ChatForum
//
//  Created by David Buhauer on 09/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit
import AlamofireImage

protocol CFForumCellDelegate: class {
    func didTapLikeButton(liked: Bool, sender: CFForumCell)
    func didTapDislikeButton(disliked: Bool, sender: CFForumCell)
}

class CFForumCell: UITableViewCell, Reusable {
    @IBOutlet weak var forumTextLabel: UILabel!
    @IBOutlet weak var forumDateLabel: UILabel!
    @IBOutlet weak var forumCommentView: UIView!
    @IBOutlet weak var forumCommentIcon: UIImageView!
    @IBOutlet weak var forumLikeIcon: UIImageView!
    @IBOutlet weak var forumDislikeIcon: UIImageView!
    @IBOutlet weak var forumImageView: UIImageView!
    @IBOutlet weak var forumNumberOfCommentsLabel: UILabel!
    @IBOutlet weak var forumNumberOfLikesLabel: UILabel!
    @IBOutlet weak var forumNumberOfDislikesLabel: UILabel!
    @IBOutlet weak var forumLikeButton: UIButton!
    @IBOutlet weak var forumDislikeButton: UIButton!
    @IBOutlet weak var seperator: UIView!
    
    weak var delegate: CFForumCellDelegate?
    
    var post: CFPost?
    var comment: CFComment?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.forumTextLabel.textColor = .white
        self.forumDateLabel.textColor = .white
        self.forumNumberOfCommentsLabel.textColor = .white
        self.forumNumberOfLikesLabel.textColor = .white
        self.forumNumberOfDislikesLabel.textColor = .white
        
        self.forumCommentIcon.image = #imageLiteral(resourceName: "icons8-comments-filled-100").withRenderingMode(.alwaysTemplate)
        self.forumCommentIcon.tintColor = .white
        
        self.forumLikeButton.setImage(#imageLiteral(resourceName: "icons8-thumbs-up-100").withRenderingMode(.alwaysTemplate), for: .normal)
        self.forumLikeButton.setImage(#imageLiteral(resourceName: "icons8-thumbs-up-filled-100").withRenderingMode(.alwaysTemplate), for: .selected)
        self.forumLikeButton.tintColor = .white
        
        self.forumDislikeButton.setImage(#imageLiteral(resourceName: "icons8-thumbs-down-100").withRenderingMode(.alwaysTemplate), for: .normal)
        self.forumDislikeButton.setImage(#imageLiteral(resourceName: "icons8-thumbs-down-filled-100").withRenderingMode(.alwaysTemplate), for: .selected)
        self.forumDislikeButton.tintColor = .white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        forumImageView.af_cancelImageRequest()
        forumImageView.image = nil
        
        forumNumberOfCommentsLabel.text = "0"
        forumNumberOfLikesLabel.text = "0"
        forumNumberOfDislikesLabel.text = "0"
        
        forumLikeButton.isSelected = false
        forumDislikeButton.isSelected = false
        
        post = nil
        comment = nil
    }
    
    static var nib: UINib? {
        return UINib(nibName: String(describing: CFForumCell.self), bundle: nil)
    }
    
    @IBAction func didTapLikeButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.didTapLikeButton(liked: sender.isSelected, sender: self)
    }
    
    @IBAction func didTapDislikeButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.didTapDislikeButton(disliked: sender.isSelected, sender: self)
    }
}
