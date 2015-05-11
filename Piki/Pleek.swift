//
//  Pleek.swift
//  Peekee
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation
    
class Pleek: PFObject, PFSubclassing {
    @NSManaged var extraSmallPiki: PFFile
    @NSManaged var photo: PFFile
    @NSManaged var previewImage: PFFile
    @NSManaged var react1: PFFile
    @NSManaged var react2: PFFile
    @NSManaged var react3: PFFile
    @NSManaged var isPublic: Bool
    @NSManaged var nbReaction: Int
    
    class func parseClassName() -> String {
        return "Piki"
    }
}