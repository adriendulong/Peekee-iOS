//
//  SearchUserTableViewCell.swift
//  Peekee
//
//  Created by Kevin CATHALY on 05/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation

class SearchUserTableViewCell : UITableViewCell {
    
    var user:User?
    var searchUsernameLabel:UILabel?
    var loadIndicator:UIActivityIndicatorView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    func setupView() {
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.Theme.CellHighlightColor
        self.selectedBackgroundView = bgColorView
        
        var separatorView = UIView()
        separatorView.backgroundColor = UIColor.Theme.CellSeparatorColor
        self.contentView.addSubview(separatorView)
        
        separatorView.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.contentView.snp_leading)
            make.trailing.equalTo(self.contentView.snp_trailing)
            make.height.equalTo(Dimensions.CellSeparatorHeight)
            make.bottom.equalTo(self.contentView.snp_bottom)
        }
    }
    
    func loadItemLoading(searchUsername : String, isSearching : Bool){
        
        if searchUsernameLabel == nil{
            searchUsernameLabel = UILabel(frame: CGRect(x: 20, y: 0, width: UIScreen.mainScreen().bounds.width - 40, height: 60))
            searchUsernameLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 20)
            searchUsernameLabel!.textColor = UIColor.blackColor()
            contentView.addSubview(searchUsernameLabel!)
        }
        
        searchUsernameLabel!.text = "@\(searchUsername)"
        
        if loadIndicator == nil{
            loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            loadIndicator!.tintColor = Utils().secondColor
            loadIndicator!.center = CGPoint(x: UIScreen.mainScreen().bounds.width - 20 , y: 30)
            loadIndicator!.hidesWhenStopped = true
            self.addSubview(loadIndicator!)
        }
        
        if isSearching{
            loadIndicator!.startAnimating()
        }
        else{
            loadIndicator!.stopAnimating()
        }
        
    }
    
}