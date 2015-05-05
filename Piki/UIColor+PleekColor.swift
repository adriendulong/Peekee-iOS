//
//  UIColor+PleekColor.swift
//  Peekee
//
//  Created by Kevin CATHALY on 05/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import UIKit

extension UIColor {
    
    private struct PrivateColors {
        // Base palette
        static let LightGrey: UIColor = UIColor(white: 250.0/255.0, alpha: 1.0)
        static let Grey: UIColor = UIColor(white: 234.0/255.0, alpha: 1.0)
    }
    
    struct Theme {
        static let CellHighlightColor = PrivateColors.LightGrey
        static let CellSeparatorColor = PrivateColors.Grey
    }
}
