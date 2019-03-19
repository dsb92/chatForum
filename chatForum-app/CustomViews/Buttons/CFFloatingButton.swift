//
//  CFFloatingButton.swift
//  chatForum-app
//
//  Created by David Buhauer on 19/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit

class CFFloatingButton: UIButton {

    required init() {
        super.init(frame: .zero)
        
        self.commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.bounds.size.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.clipsToBounds = true
        self.backgroundColor = UIColor.orange
        self.setImage(#imageLiteral(resourceName: "icons8-plus-math-filled-100"), for: .normal)
    }
}
