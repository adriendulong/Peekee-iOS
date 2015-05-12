//
//  Friend.swift
//  Peekee
//
//  Created by Kevin CATHALY on 12/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation

class Friend: PFObject, PFSubclassing {
    
    @NSManaged var friend: User
    @NSManaged var user: User
    @NSManaged var friendId: String
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Friend"
    }
}