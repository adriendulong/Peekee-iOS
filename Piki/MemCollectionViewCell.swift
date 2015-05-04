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
    var selectorImageView:UIImageView!
    var innerShadowImageView:UIImageView!
    var labelDemoFont:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        selectedEmoji = false
        
        innerShadowImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        innerShadowImageView.contentMode = UIViewContentMode.ScaleAspectFit
        innerShadowImageView.hidden = true
        innerShadowImageView.image = UIImage(named: "inner_shadow_selected_cell")
        contentView.addSubview(innerShadowImageView)
        
        iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        iconImageView.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(iconImageView)

        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        loadIndicator.center = CGPoint(x: frame.width/2, y: frame.height/2)
        loadIndicator.hidesWhenStopped = true
        contentView.addSubview(loadIndicator)
        
        labelDemoFont = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        labelDemoFont.font = UIFont(name: Utils().montserratBold, size: 30)
        labelDemoFont.textColor = UIColor.whiteColor()
        labelDemoFont.text = "YO"
        labelDemoFont.hidden = true
        labelDemoFont.textAlignment = NSTextAlignment.Center
        contentView.addSubview(labelDemoFont)
        
        contentView.backgroundColor = UIColor(red: 53/255, green: 54/255, blue: 55/255, alpha: 1.0)
        
        selectorImageView = UIImageView(frame: CGRect(x: frame.width - 32, y: 10, width: 22, height: 22))
        selectorImageView.image = UIImage(named: "font_meme_selected")
        selectorImageView.hidden = true
        contentView.addSubview(selectorImageView)
        
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}