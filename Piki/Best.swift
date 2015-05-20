//
//  Best.swift
//  Peekee
//
//  Created by Kevin CATHALY on 20/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation

@objc class Best: PFObject, PFSubclassing {
    
    @NSManaged var pleek: Pleek?
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Best"
    }
    
    class func getAllBest(withCache: Bool, skip: Int, completed: (bests: [Best]?, error: NSError?) -> Void) {
        let query = Best.query()!
        query.orderByDescending("updatedAt")
        query.limit = Constants.LoadPleekLimit
        query.includeKey("pleek.user")
        
        if withCache {
            query.cachePolicy = PFCachePolicy.CacheThenNetwork
        } else {
            query.cachePolicy = PFCachePolicy.NetworkElseCache
        }
        
        query.findObjectsInBackgroundWithBlock { (bests, error) -> Void in
            completed(bests: bests as? [Best], error: error)
        }
    }
}