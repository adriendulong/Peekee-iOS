//
//  PleekBestCollectionViewLayout.swift
//  Peekee
//
//  Created by Kevin CATHALY on 19/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import UIKit

class PleekBestCollectionViewLayout: UICollectionViewFlowLayout {
   
    var size: CGRect
    
    init(size: CGRect) {
        self.size = size
        super.init()
        self.setup()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        
    }
    
    
}
