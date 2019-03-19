//
//  ColorUtil.swift
//  chatForum-app
//
//  Created by David Buhauer on 19/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import Foundation
import UIKit

struct ColorUtil {
    static var randomColor: UIColor {
        get {
            let number = Int.random(in: 0 ..< ColorUtil.colors.count)
            return UIColor(hexString: ColorUtil.colors[number])
        }
    }
    
    private static var colors: [String] {
        get {
            return ["#e5000f",
            "#fcc500",
            "#00db8a",
            "00a4db",
            "#12bc00"]
        }
    }
}
