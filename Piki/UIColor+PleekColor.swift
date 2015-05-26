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
        static let LightGreyBlue = UIColor(red: 242.0/255.0, green: 245.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        static let DarkGreyBlue = UIColor(red: 128.0/255.0, green: 137.0/255.0, blue: 147.0/255.0, alpha: 1.0)
        static let GreyBlue = UIColor(red: 161.0/255.0, green: 175.0/255.0, blue: 191.0/255.0, alpha: 1.0)
        static let Red = UIColor(red: 239.0/255.0, green: 83.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    }
    
    struct Theme {
        static let CellHighlightColor = PrivateColors.VeryLightGrey
        static let CellSeparatorColor = PrivateColors.LightGrey
        static let BackgroundNewPleekMenuColor = PrivateColors.DarkGrey
        static let BezelLightColor = PrivateColors.Grey
        static let BezelDarkColor = PrivateColors.Black
        static let PleekBackGroundColor = PrivateColors.LightGreyBlue
        static let PleekSpinnerColor = PrivateColors.DarkGreyBlue
        static let DarkTextColor = PrivateColors.GreyBlue
        static let DeletePleekBackGroundColor = PrivateColors.Red
    }
}
