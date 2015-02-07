//
//  DoubleInboxCollectionViewCell.swift
//  Piki
//
//  Created by Adrien Dulong on 23/10/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation


class DoubleInboxCollectionViewCell : UICollectionViewCell{
    
    let newView:UIView!
    let newLabel:UILabel!
    let mainImage:PFImageView!
    let reactView:UIView!
    let previewReacts:PFImageView!
    let previewReactsNbAnswers:PFImageView!
    let iconReact:UIImageView!
    let nbReactsLabel:UILabel!
    let infosView:UIView!
    let usernameLabel:UILabel!
    var reactImagesView:UIView!
    var nbReactView : UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(red: 238/255, green: 233/255, blue: 239/255, alpha: 1.0)
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        
        //Main Imag3
        mainImage = PFImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        mainImage.contentMode = UIViewContentMode.ScaleAspectFill
        contentView.addSubview(mainImage)
        
        //Bezier borders
        /*var shapeLayer:CAShapeLayer = CAShapeLayer()
        shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        shapeLayer.path = UIBezierPath(roundedRect: mainImage.bounds, cornerRadius : 30.0).CGPath
        
        mainImage.layer.masksToBounds = true
        mainImage.layer.mask = shapeLayer
        shapeLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width - 20, height: frame.size.height - 20)*/
        
        
        
        infosView = UIView(frame: CGRectMake(0, frame.size.height - 45, frame.size.width, 45))
        infosView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(infosView)
        
        var backgroundInfosView = UIView(frame: CGRectMake(0, 0, infosView.frame.size.width, infosView.frame.size.height))
        backgroundInfosView.backgroundColor = UIColor.whiteColor()
        backgroundInfosView.alpha = 0.7
        infosView.addSubview(backgroundInfosView)
        
        var fromLabel = UILabel(frame: CGRect(x: 6, y: 5, width: 50, height: 20))
        fromLabel.textColor = Utils().darkColor
        fromLabel.font = UIFont(name: Utils().customFont, size: 11.0)
        fromLabel.textAlignment = NSTextAlignment.Left
        fromLabel.text = "From:"
        infosView.addSubview(fromLabel)
        
        usernameLabel = UILabel(frame: CGRectMake(6, 20, infosView.frame.size.width, 20))
        usernameLabel.textColor = Utils().darkColor
        usernameLabel.font = UIFont(name: Utils().customFont, size: 16.0)
        usernameLabel.textAlignment = NSTextAlignment.Left
        usernameLabel.text = "adulong"
        infosView.addSubview(usernameLabel)
        
        nbReactsLabel = UILabel(frame: CGRect(x: frame.size.width - 22 - 50, y: 13, width: 50, height: 20))
        nbReactsLabel.font = UIFont(name: Utils().customFont, size: 16)
        nbReactsLabel.textColor = Utils().darkColor
        nbReactsLabel.text = "30"
        nbReactsLabel.textAlignment = NSTextAlignment.Right
        infosView.addSubview(nbReactsLabel)
        
        //React Icon
        iconReact = UIImageView(frame: CGRect(x: frame.size.width - 5 - 13, y: 19, width: 13, height: 9))
        iconReact.image = UIImage(named: "icon_reply")
        infosView.addSubview(iconReact)
        
        //New view
        newView = UIView(frame: CGRect(x: contentView.frame.size.width/2 - 45, y: contentView.frame.size.height - 45 - 11, width: 80, height: 22))
        newView.backgroundColor = Utils().redColor
        newView.layer.cornerRadius = 10
        newView.clipsToBounds = true
        contentView.addSubview(newView)
        
        newLabel = UILabel(frame: CGRect(x: 0, y: 0, width: newView.frame.size.width, height: newView.frame.size.height))
        newLabel.font = UIFont(name: Utils().customFont, size: 12.0)
        newLabel.textColor = UIColor.whiteColor()
        newLabel.textAlignment = NSTextAlignment.Center
        newLabel.text = "3 New React"
        newView.addSubview(newLabel)
        
        
        
        
        
        //React View
        //UIColor(red: 53/255, green: 45/255, blue: 60/255, alpha: 1.0)
        reactView = UIView(frame: CGRect(x: infosView.frame.size.width/2, y: 0, width: infosView.frame.size.width/2, height: infosView.frame.size.height))
        reactView.backgroundColor = UIColor.clearColor()
        //infosView.addSubview(reactView)
        
        // Nb Reacts
        nbReactView = UIView(frame: CGRectMake(10, 5, 40, 40))
        nbReactView.backgroundColor = UIColor(red: 238/255, green: 233/255, blue: 239/255, alpha: 1.0)
        nbReactView.layer.cornerRadius = 20
        nbReactView.clipsToBounds = true
        reactView.addSubview(nbReactView)
        
        previewReactsNbAnswers = PFImageView(frame: CGRect(x: 1, y: 1, width: nbReactView.frame.size.width - 2, height: nbReactView.frame.size.height - 2))
        previewReactsNbAnswers.animationDuration = 3
        previewReactsNbAnswers.clipsToBounds = true
        previewReactsNbAnswers.layer.cornerRadius = (nbReactView.frame.size.width - 2)/2
        previewReactsNbAnswers.startAnimating()
        nbReactView.addSubview(previewReactsNbAnswers)
        
        // Images preview
        reactImagesView = UIView(frame: CGRectMake(reactView.frame.size.width - 50, 5, 40, 40))
        reactImagesView.backgroundColor = UIColor(red: 238/255, green: 233/255, blue: 239/255, alpha: 1.0)
        reactImagesView.layer.cornerRadius = 20
        reactImagesView.clipsToBounds = true
        reactView.addSubview(reactImagesView)

        previewReacts = PFImageView(frame: CGRect(x: 1, y: 1, width: reactImagesView.frame.size.width - 2, height: reactImagesView.frame.size.height - 2))
        previewReacts.animationDuration = 3
        previewReacts.clipsToBounds = true
        previewReacts.layer.cornerRadius = (reactImagesView.frame.size.width - 2)/2
        reactImagesView.addSubview(previewReacts)
        //nbReactView.addSubview(previewReacts)
        
        //Layer above photos in nb reacts view
        var layerViewNbReacts = UIView(frame: CGRectMake(1, 1, nbReactView.frame.size.width - 2, nbReactView.frame.size.height - 2))
        layerViewNbReacts.backgroundColor = UIColor.blackColor()
        layerViewNbReacts.alpha = 0.6
        layerViewNbReacts.clipsToBounds = true
        layerViewNbReacts.layer.cornerRadius = (reactImagesView.frame.size.width - 2)/2
        nbReactView.addSubview(layerViewNbReacts)
        
        
        //Label with nb of reacts
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
}