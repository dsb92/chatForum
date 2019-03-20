//
//  CFCommentCell.swift
//  chatForum-app
//
//  Created by David Buhauer on 20/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit

class CFCommentCell: CFForumCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.seperator.isHidden = true
    }
}
