//
//  EmojiLikeCollectionViewCell.swift
//  Piki
//
//  Created by Adrien Dulong on 14/10/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation


class EmojiLikeCollectionViewCell : UICollectionViewCell {
    
    let emojiImage:UIImageView!
    let backViewGray:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backViewGray = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        backViewGray.backgroundColor = UIColor.blackColor()
        backViewGray.alpha = 0.7
        contentView.addSubview(backViewGray)
        emojiImage = UIImageView(frame: CGRect(x: frame.size.width/2 - 75, y: frame.size.height/2 - 75, width: 150, height: 150))
        emojiImage.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(emojiImage)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}