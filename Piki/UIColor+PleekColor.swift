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
        static let VeryLightGrey: UIColor = UIColor(white: 250.0/255.0, alpha: 1.0)
        static let LightGrey: UIColor = UIColor(white: 234.0/255.0, alpha: 1.0)
        static let DarkGrey: UIColor = UIColor(red: 68.0/255, green: 70.0/255, blue: 72.0/255, alpha: 1.0)
        static let Black: UIColor = UIColor(white: 0.0/255.0, alpha: 1.0)
        static let Grey: UIColor = UIColor(white: 101.0/255.0, alpha: 1.0)
    }
    
    struct Theme {
        static let CellHighlightColor = PrivateColors.VeryLightGrey
        static let CellSeparatorColor = PrivateColors.LightGrey
        static let BackgroundNewPleekMenuColor = PrivateColors.DarkGrey
        static let BezelLightColor = PrivateColors.Grey
        static let BezelDarkColor = PrivateColors.Black
    }
}
