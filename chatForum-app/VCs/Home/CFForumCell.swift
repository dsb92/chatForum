//
//  CFForumCell.swift
//  ChatForum
//
//  Created by David Buhauer on 09/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit

class CFForumCell: UITableViewCell, Reusable {
    @IBOutlet weak var forumTextLabel: UILabel!
    @IBOutlet weak var forumDateLabel: UILabel!
    @IBOutlet weak var forumCommentView: UIView!
    @IBOutlet weak var forumCommentIcon: UIImageView!
    @IBOutlet weak var forumNumberOfCommentsLabel: UILabel!
    @IBOutlet weak var seperator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.forumTextLabel.textColor = .white
        self.forumDateLabel.textColor = .white
        self.forumNumberOfCommentsLabel.textColor = .white
        
        self.forumCommentIcon.image = #imageLiteral(resourceName: "icons8-comments-filled-100").withRenderingMode(.alwaysTemplate)
        self.forumCommentIcon.tintColor = .white
    }
    
    static var nib: UINib? {
        return UINib(nibName: String(describing: CFForumCell.self), bundle: nil)
    }
}
