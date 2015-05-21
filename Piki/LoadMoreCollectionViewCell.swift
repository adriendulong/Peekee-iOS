//
//  LoadMoreCollectionViewCell.swift
//  Peekee
//
//  Created by Kevin CATHALY on 20/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import UIKit

class LoadMoreCollectionViewCell: UICollectionViewCell {
    lazy var spinner: LLARingSpinnerView = {
        let spinner = LLARingSpinnerView()
        spinner.hidesWhenStopped = true
        spinner.lineWidth = Dimensions.SpinnerLineFatWidth
        spinner.tintColor = UIColor.Theme.PleekSpinnerColor
        spinner.backgroundColor = UIColor.clearColor()
        
        self.contentView.addSubview(spinner)
        
        spinner.snp_makeConstraints({ (make) -> Void in
            make.center.equalTo(self.contentView.snp_center)
            make.size.equalTo(33)
        })
        
        return spinner
        } ()
    
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    func setupView() {
        self.contentView.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        self.clipsToBounds = true
        spinner.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsUpdateConstraints()
    }

}