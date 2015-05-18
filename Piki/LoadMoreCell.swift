//
//  LoadMoreCell.swift
//  Peekee
//
//  Created by Kevin CATHALY on 18/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import UIKit

class LoadMoreCell: UITableViewCell {
    
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    func setupView() {
        self.contentView.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        self.clipsToBounds = true
        self.selectionStyle = .None
        spinner.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsUpdateConstraints()
    }

}
