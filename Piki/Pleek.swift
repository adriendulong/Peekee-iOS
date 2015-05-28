//
//  Pleek.swift
//  Peekee
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation

enum PleekState {
    case NotSeenVideo
    case NotSeenPhoto
    case SeenNotNewReact
    case SeenNewReact
}
    
@objc class Pleek: PFObject, PFSubclassing {
    
    @NSManaged var extraSmallPiki: PFFile?
    @NSManaged var photo: PFFile?
    @NSManaged var previewImage: PFFile?
    @NSManaged var react1: PFFile?
    @NSManaged var react2: PFFile?
    @NSManaged var react3: PFFile?
    @NSManaged var video: PFFile?
    @NSManaged var isPublic: Bool
    @NSManaged var nbReaction: Int
    @NSManaged var user: User
    @NSManaged var recipients: [String]?
    @NSManaged var lastUpdate: NSDate?
    
    var lastUpdateDate: NSDate {
        if let lastUpdate = self.lastUpdate {
            return lastUpdate
        }
        
        return NSDate(timeIntervalSince1970: 0)
    }
    
    
    var state: PleekState {
        if self.isSeen {
            if self.nbNewReaction > 0 {
                return .SeenNewReact
            }
            return .SeenNotNewReact
        } else {
            if self.isVideo {
                return .NotSeenVideo
            }
            return .NotSeenPhoto
        }
    }
    
    var react: [React] = []
    
    var nbNewReaction: Int {
        if let infos = self.infos, let nbReactions = infos["nbReaction"] as? Int  {
            return self.nbReaction - nbReactions
        }
        
        return 0
    }
    
    var isVideo: Bool {
        if let video = self.video {
            return true
        }
        
        return false
    }
    
    var isSeen: Bool {
        if let infos = self.infos {
            return true
        }
        
        return false
    }
    
    var infos: [String: AnyObject]? {
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        return defaults.objectForKey(self.objectId!) as? [String: AnyObject]
    }
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Piki"
    }
    
    func getRealRecipientsNumber() -> Int {
        var recipients: [String] = self.recipients ?? []
        recipients.removeObject(self.user.objectId!)
        
        return count(recipients)
    }
    
    func deleteOrHide(completion: ((result : AnyObject?, error : NSError?) -> Void)?) {
        if self.user.objectId == User.currentUser()!.objectId || !self.isPublic {
            PFCloud.callFunctionInBackground("hideOrRemovePikiV2",
                withParameters: ["pikiId" : self.objectId!], block: { (result : AnyObject?, error : NSError?) -> Void in
                    if let completion = completion {
                        completion(result : result, error : error)
                    }
            })
        } else {
            Utils().hidePleek(self.objectId!)
        }
    }
    
    class func getBestPleek() -> (withCache: Bool, skip: Int, completed: PleekCompletionHandler) -> () {
        func local(withCache: Bool, skip: Int, completed: PleekCompletionHandler) {
            Best.getAllBest(withCache, skip: skip) { (bests, error) -> () in
                var pleeks: [Pleek]?
                
                if let bests: [Best] = bests {
                    pleeks = []
                    bests.map { (best: Best) -> () in
                        if let pleek: Pleek = best.pleek {
                            pleeks?.append(pleek)
                        }
                    }
                }
                completed(pleeks: pleeks, error: error)
            }
        }
        
        return local
    }
    
//    class func getBestPleek(withCache: Bool, skip: Int, completed: (pleeks: [Pleek]?, error: NSError?) -> Void) {
//        Best.getAllBest(withCache, skip: skip) { (bests, error) -> () in
//            var pleeks: [Pleek]?
//            
//            if let bests: [Best] = bests {
//                pleeks = []
//                bests.map { (best: Best) -> () in
//                    if let pleek: Pleek = best.pleek {
//                        pleeks?.append(pleek)
//                    }
//                }
//            }
//            completed(pleeks: pleeks, error: error)
//        }
//    }
    
    class func find(user: User, skip: Int) -> BFTask {
        
        
        let predicate = NSPredicate(format: "isPublic = \(true) OR '\(User.currentUser()!.objectId!)' IN recipients", argumentArray: nil)
        let query = Pleek.queryWithPredicate(predicate)!
        query.orderByDescending("lastUpdate")
        query.whereKey("user", equalTo: user)
        query.includeKey("user")

        query.cachePolicy = PFCachePolicy.NetworkElseCache
        
        query.limit = Constants.LoadPleekLimit
        query.skip = skip
        
        return query.findObjectsInBackground()
    }
}