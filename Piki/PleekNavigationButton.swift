//
//  PleekNavigationButton.swift
//  POCTopBar
//
//  Created by Kevin CATHALY on 13/05/2015.
//  Copyright (c) 2015 Kevin CATHALY. All rights reserved.
//

import UIKit

class PleekNavigationButton: UIButton {
    
    private let normalImage: UIImage?
    private let selectedImage: UIImage?
    
    var newContent: Bool = false {
        didSet {
            if newContent {
                self.newContentIndicatorView.hidden = false
            } else {
                self.newContentIndicatorView.hidden = true
            }
        }
    }
    
    private lazy var containerView: UIView = {
        let containerV = UIView()
        containerV.userInteractionEnabled = false
        containerV.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        
        self.addSubview(containerV)
        
        containerV.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.snp_centerY)
            make.centerX.equalTo(self.snp_centerX).offset(5.5)
        }
        
        return containerV
    } ()
    
    private lazy var iconImageView: UIImageView = {
        let iconIV = UIImageView()
        iconIV.contentMode = .Center
        iconIV.userInteractionEnabled = false
        iconIV.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        
        self.containerView.addSubview(iconIV)
        
        iconIV.snp_makeConstraints{ (make) -> Void in
            make.leading.equalTo(self.containerView.snp_leading)
            make.centerY.equalTo(self.containerView.snp_centerY)
            make.width.equalTo(12.5)
            make.height.equalTo(15)
        }
        
        return iconIV
    } ()
    
    private lazy var textLabel: UILabel = {
        let textL = UILabel()
        textL.userInteractionEnabled = false
        textL.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        textL.textColor = UIColor.whiteColor()
        textL.font = UIFont(name: "ProximaNova-Bold", size: 13.0)!
        
        self.containerView.addSubview(textL)
        
        textL.snp_makeConstraints{ (make) -> Void in
            make.leading.equalTo(self.iconImageView.snp_trailing).offset(6)
            make.centerY.equalTo(self.iconImageView.snp_centerY)
        }
        
        return textL
    } ()
    
    private lazy var newContentIndicatorView: UIImageView = {
        let newCIV = UIImageView()
        newCIV.userInteractionEnabled = false
        newCIV.backgroundColor = UIColor(red: 62.0/255.0, green: 80.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        newCIV.image = UIImage(named: "notification-badge")
        
        self.containerView.addSubview(newCIV)
        
        newCIV.snp_makeConstraints{ (make) -> Void in
            make.leading.equalTo(self.textLabel.snp_trailing).offset(6)
            make.centerY.equalTo(self.containerView.snp_centerY)
            make.size.equalTo(5)
        }
        
        return newCIV
    } ()
    
    override var selected: Bool {
        didSet {
            if selected {
                self.iconImageView.image = selectedImage
            } else {
                self.iconImageView.image = normalImage
            }
        }
    }
    
    // MARK: Life Cycle
    
    init(image: UIImage?, selectedImage: UIImage?, text: String) {
        self.normalImage = image
        self.selectedImage = selectedImage
        super.init(frame: CGRectZero)
        
        self.iconImageView.image = self.normalImage
        self.textLabel.text = text
        
        self.needsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        self.containerView.snp_updateConstraints{ (make) -> Void in
            make.width.equalTo(self.textLabel.snp_width).offset(17.5 + 6 + 6)
            make.height.equalTo(self.textLabel.snp_height)
        }
       
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsUpdateConstraints()
    }
}

