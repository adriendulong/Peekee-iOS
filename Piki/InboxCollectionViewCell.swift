//
//  InboxCollectionViewCell.swift
//  Piki
//
//  Created by Adrien Dulong on 22/10/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation

class InboxCollectionViewCell : UICollectionViewCell {
    
    let mainImage:PFImageView!
    let nbReactView:UIView!
    let labelUserName:UILabel!
    let labelNbReact:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //Main Image
        mainImage = PFImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        contentView.addSubview(mainImage)
        
        //React and User indicator
        nbReactView = UIView(frame: CGRect(x: 6, y: frame.height-23, width: frame.width-12, height: 17))
        nbReactView.layer.cornerRadius = 2
        nbReactView.clipsToBounds = true
        contentView.addSubview(nbReactView)
        
        //Label user name
        labelUserName = UILabel(frame: CGRect(x: 5, y: 0, width: nbReactView.frame.width/2, height: nbReactView.frame.height))
        labelUserName.textColor = UIColor.whiteColor()
        labelUserName.font = UIFont(name: "HelveticaNeue-Medium", size: 10.0)
        nbReactView.addSubview(labelUserName)
        
        //Label Nb Answers
        labelNbReact = UILabel(frame: CGRect(x: nbReactView.frame.width/4*3 - 5, y: 0, width: nbReactView.frame.width/4, height: nbReactView.frame.height))
        labelNbReact.textColor = UIColor.whiteColor()
        labelNbReact.font = UIFont(name: "HelveticaNeue-Medium", size: 10.0)
        labelNbReact.text = "145"
        labelNbReact.textAlignment = NSTextAlignment.Right
        nbReactView.addSubview(labelNbReact)
        
        //Icon Answers
        let iconAnswer = UIImageView(frame: CGRect(x: nbReactView.frame.width/4*3 - 5, y: nbReactView.frame.size.height/2-5, width: 11, height: 10))
        iconAnswer.image = UIImage(named: "answer")
        nbReactView.addSubview(iconAnswer)
        
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}