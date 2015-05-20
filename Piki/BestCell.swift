//
//  BestCell.swift
//  Peekee
//
//  Created by Kevin CATHALY on 20/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import UIKit

class BestCell: UICollectionViewCell {
    
    lazy var containerView: UIView = {
        let containerV = UIView()
        containerV.backgroundColor = UIColor.whiteColor()
        
        self.contentView.addSubview(containerV)
        
        containerV.snp_makeConstraints({ (make) -> Void in
            make.leading.equalTo(self.contentView)
            make.trailing.equalTo(self.contentView)
            make.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
        })
        
        containerV.layer.borderWidth = 0.5
        containerV.layer.borderColor = UIColor.whiteColor().CGColor
        containerV.layer.cornerRadius = 3.0
        containerV.clipsToBounds = true
        
        return containerV
    } ()
    
    lazy var pleekImageView: PFImageView = {
        let pleekIV = PFImageView()
        pleekIV.backgroundColor = UIColor.Theme.PleekBackGroundColor
        
        self.containerView.addSubview(pleekIV)
        
        pleekIV.snp_makeConstraints({ (make) -> Void in
            make.leading.equalTo(self.containerView)
            make.trailing.equalTo(self.containerView)
            make.top.equalTo(self.containerView)
            make.height.equalTo(self.containerView.snp_width)
        })
        
        return pleekIV
    } ()
    
    lazy var pleekPlayImageView: PFImageView = {
        let pleekPIM = PFImageView()
        pleekPIM.backgroundColor = UIColor.clearColor()
        pleekPIM.image = UIImage(named: "video-icon-big")
        
        self.pleekImageView.addSubview(pleekPIM)
        
        pleekPIM.snp_makeConstraints({ (make) -> Void in
            make.width.equalTo(31)
            make.height.equalTo(37.5)
            make.center.equalTo(self.pleekImageView)
        })
        
        return pleekPIM
    } ()
    
    lazy var pleekImageSpinner: LLARingSpinnerView = {
        let pleekIS = LLARingSpinnerView()
        pleekIS.hidesWhenStopped = true
        pleekIS.backgroundColor = UIColor.clearColor()
        pleekIS.tintColor = UIColor.Theme.PleekSpinnerColor
        pleekIS.lineWidth = Dimensions.SpinnerLineFatWidth
        self.pleekImageView.addSubview(pleekIS)
        
        pleekIS.snp_makeConstraints({ (make) -> Void in
            make.center.equalTo(self.pleekImageView)
            make.size.equalTo(30)
        })
        
        return pleekIS
    } ()
    
    lazy var react1ImaveView: PFImageView = {
        let reactIV = PFImageView()
        reactIV.backgroundColor = UIColor.Theme.PleekBackGroundColor
        
        self.containerView.addSubview(reactIV)
        
        reactIV.snp_makeConstraints({ (make) -> Void in
            make.leading.equalTo(self.containerView)
            make.top.equalTo(self.pleekImageView.snp_bottom).offset(0.5)
            make.bottom.equalTo(self.containerView)
            make.width.equalTo((CGRectGetWidth(self.frame) - 1.0)/3.0)
        })
        
        return reactIV
    } ()
    
    lazy var react1Spinner: LLARingSpinnerView = {
        let spinner = LLARingSpinnerView()
        spinner.hidesWhenStopped = true
        spinner.backgroundColor = UIColor.clearColor()
        spinner.tintColor = UIColor.Theme.PleekSpinnerColor
        spinner.lineWidth = Dimensions.SpinnerLineThinWidth
        self.react1ImaveView.addSubview(spinner)
        
        spinner.snp_makeConstraints({ (make) -> Void in
            make.center.equalTo(self.react1ImaveView)
            make.size.equalTo(16)
        })
        
        return spinner
    } ()
    
    lazy var react2ImaveView: PFImageView = {
        let reactIV = PFImageView()
        reactIV.backgroundColor = UIColor.Theme.PleekBackGroundColor
        
        self.containerView.addSubview(reactIV)
        
        reactIV.snp_makeConstraints({ (make) -> Void in
            make.centerX.equalTo(self.containerView)
            make.top.equalTo(self.react1ImaveView)
            make.bottom.equalTo(self.containerView)
            make.width.equalTo(self.react1ImaveView)
        })
        
        return reactIV
    } ()
    
    lazy var react2Spinner: LLARingSpinnerView = {
        let spinner = LLARingSpinnerView()
        spinner.hidesWhenStopped = true
        spinner.backgroundColor = UIColor.clearColor()
        spinner.tintColor = UIColor.Theme.PleekSpinnerColor
        spinner.lineWidth = Dimensions.SpinnerLineThinWidth
        self.react2ImaveView.addSubview(spinner)
        
        spinner.snp_makeConstraints({ (make) -> Void in
            make.center.equalTo(self.react2ImaveView)
            make.size.equalTo(16)
        })
        
        return spinner
    } ()
    
    lazy var react3ImaveView: PFImageView = {
        let reactIV = PFImageView()
        reactIV.backgroundColor = UIColor.Theme.PleekBackGroundColor
        
        self.containerView.addSubview(reactIV)
        
        reactIV.snp_makeConstraints({ (make) -> Void in
            make.trailing.equalTo(self.containerView)
            make.top.equalTo(self.react1ImaveView)
            make.bottom.equalTo(self.containerView)
            make.width.equalTo(self.react1ImaveView)
        })
        
        return reactIV
    } ()
    
    lazy var react3Spinner: LLARingSpinnerView = {
        let spinner = LLARingSpinnerView()
        spinner.hidesWhenStopped = true
        spinner.backgroundColor = UIColor.clearColor()
        spinner.tintColor = UIColor.Theme.PleekSpinnerColor
        spinner.lineWidth = Dimensions.SpinnerLineThinWidth
        self.react3ImaveView.addSubview(spinner)
        
        spinner.snp_makeConstraints({ (make) -> Void in
            make.center.equalTo(self.react3ImaveView)
            make.size.equalTo(16)
        })
        
        return spinner
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    func setupView() {
        self.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        self.contentView.backgroundColor = UIColor.clearColor()
        let containerView = self.containerView
        let pleekS = self.pleekImageSpinner
        let react1 = self.react1Spinner
        let react2 = self.react2Spinner
        let react3 = self.react3Spinner
        let play = self.pleekPlayImageView
        
        self.contentView.backgroundColor = UIColor.Theme.PleekBackGroundColor
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.shadowColor = UIColor.blackColor().CGColor
        self.contentView.layer.shadowOffset = CGSizeMake(0, 0)
        self.contentView.layer.shadowOpacity = 0.4
        self.contentView.layer.shadowRadius = 2.0
    }
}

extension BestCell {
    func configureFor(pleek: Pleek) {
        weak var weakSelf = self
        
        self.pleekImageView.image = nil
        self.pleekImageSpinner.startAnimating()
        self.pleekPlayImageView.hidden = true
        
        if pleek.isVideo {
            self.pleekImageView.file = pleek.previewImage
        } else {
            self.pleekImageView.file = pleek.photo
        }
        
        self.pleekImageView.loadInBackground { (image, error) -> Void in
            weakSelf?.pleekImageSpinner.stopAnimating()
            if pleek.isVideo {
                self.pleekPlayImageView.hidden = false
            }
        }

        self.react1ImaveView.image = nil
        
        if let react = pleek.react1 {
            self.react1Spinner.startAnimating()
            self.react1ImaveView.file = react
            self.react1ImaveView.loadInBackground { (image, error) -> Void in
                weakSelf?.react1Spinner.stopAnimating()
            }
        }
        
        self.react2ImaveView.image = nil
        
        if let react = pleek.react2 {
            self.react2Spinner.startAnimating()
            self.react2ImaveView.file = react
            self.react2ImaveView.loadInBackground { (image, error) -> Void in
                weakSelf?.react2Spinner.stopAnimating()
            }
        }
        
        self.react3ImaveView.image = nil
        
        if let react = pleek.react3 {
            self.react3Spinner.startAnimating()
            self.react3ImaveView.file = react
            self.react3ImaveView.loadInBackground { (image, error) -> Void in
                weakSelf?.react3Spinner.stopAnimating()
            }
        }
    }
}