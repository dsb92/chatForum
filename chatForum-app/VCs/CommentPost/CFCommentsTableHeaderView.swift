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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var seperator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.forumTextLabel.textColor = .white
        self.forumDateLabel.textColor = .white
    }

    static var nib: UINib? {
        return UINib(nibName: String(describing: CFCommentsTableHeaderView.self), bundle: nil)
    }
}
