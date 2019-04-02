//
//  CFCommentsTableHeaderView.swift
//  chatForum-app
//
//  Created by David Buhauer on 20/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit

class CFCommentsTableHeaderView: UITableViewHeaderFooterView, Reusable {
    
    @IBOutlet weak var forumTextLabel: UILabel!
    @IBOutlet weak var forumDateLabel: UILabel!
    @IBOutlet weak var forumCommentView: UIView!
    @IBOutlet weak var forumCommentIcon: UIImageView!
    @IBOutlet weak var forumNumberOfCommentsLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var seperator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.forumTextLabel.textColor = .white
        self.forumDateLabel.textColor = .white
        
        self.forumNumberOfCommentsLabel.textColor = .white
        
        self.forumCommentIcon.image = #imageLiteral(resourceName: "icons8-comments-filled-100").withRenderingMode(.alwaysTemplate)
        self.forumCommentIcon.tintColor = .white
    }

    static var nib: UINib? {
        return UINib(nibName: String(describing: CFCommentsTableHeaderView.self), bundle: nil)
    }
}
