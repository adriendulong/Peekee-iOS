//
//  MemCollectionViewCell.swift
//  Pleek
//
//  Created by Adrien Dulong on 23/02/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation


class MemCollectionViewCell : UICollectionViewCell{
    
    var iconImageView:UIImageView!
    var selectedEmoji:Bool!
    var loadIndicator:UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        selectedEmoji = false
        
        iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        iconImageView.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(iconImageView)

        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        loadIndicator.center = CGPoint(x: frame.width/2, y: frame.height/2)
        loadIndicator.hidesWhenStopped = true
        contentView.addSubview(loadIndicator)
        
        
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}