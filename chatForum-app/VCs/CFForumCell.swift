//
//  CFForumCell.swift
//  ChatForum
//
//  Created by David Buhauer on 09/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit

class CFForumCell: UITableViewCell {
    @IBOutlet weak var forumTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = ColorUtil.randomColor
        self.forumTextLabel.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
