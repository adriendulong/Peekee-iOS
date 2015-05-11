//
//  InboxNavigationBar.swift
//  Peekee
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import UIKit

class InboxNavigationBar: UINavigationBar {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = 120.0
        return size
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.barTintColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        self.translucent = false
//        [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x067AB5)];
//        UINavigationBar.appearance().barTintColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
