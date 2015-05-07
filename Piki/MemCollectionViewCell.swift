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
        
        innerShadowImageView = UIImageView(frame: CGRectZero)
        contentView.addSubview(innerShadowImageView)
        innerShadowImageView.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.contentView.snp_leading)
            make.trailing.equalTo(self.contentView.snp_trailing)
            make.top.equalTo(self.contentView.snp_top)
            make.bottom.equalTo(self.contentView.snp_bottom)
        }
        innerShadowImageView.contentMode = UIViewContentMode.ScaleAspectFit
        innerShadowImageView.hidden = true
        innerShadowImageView.image = UIImage(named: "inner_shadow_selected_cell")
        
        
        iconImageView = UIImageView(frame: CGRectZero)
        contentView.addSubview(iconImageView)
        iconImageView.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.contentView.snp_leading)
            make.trailing.equalTo(self.contentView.snp_trailing)
            make.top.equalTo(self.contentView.snp_top)
            make.bottom.equalTo(self.contentView.snp_bottom)
        }
        iconImageView.contentMode = UIViewContentMode.ScaleAspectFit
        

        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        contentView.addSubview(loadIndicator)
        loadIndicator.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.contentView.snp_center)
        }
        loadIndicator.hidesWhenStopped = true
        
        
        labelDemoFont = UILabel(frame: CGRectZero)
        contentView.addSubview(labelDemoFont)
        labelDemoFont.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.contentView.snp_leading)
            make.trailing.equalTo(self.contentView.snp_trailing)
            make.top.equalTo(self.contentView.snp_top)
            make.bottom.equalTo(self.contentView.snp_bottom)
        }
        labelDemoFont.font = UIFont(name: Utils().montserratBold, size: 30)
        labelDemoFont.textColor = UIColor.whiteColor()
        labelDemoFont.text = LocalizedString("YO")
        labelDemoFont.hidden = true
        labelDemoFont.textAlignment = NSTextAlignment.Center
        
        
        contentView.backgroundColor = UIColor(red: 53/255, green: 54/255, blue: 55/255, alpha: 1.0)
        
        selectorImageView = UIImageView(frame: CGRectZero)
        contentView.addSubview(selectorImageView)
        selectorImageView.snp_makeConstraints { (make) -> Void in
            make.trailing.equalTo(self.contentView.snp_trailing).offset(-32)
            make.top.equalTo(10)
            make.size.equalTo(22)
        }
        selectorImageView.image = UIImage(named: "font_meme_selected")
        selectorImageView.hidden = true
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}