//
//  User.swift
//  Peekee
//
//  Created by Kevin CATHALY on 12/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation

typealias PleekCompletionHandler = (pleeks: [Pleek]?, error: NSError?) -> ()

@objc class User: PFUser, PFSubclassing {

    @NSManaged var pleeksHided: [String]
    @NSManaged var hasSeenFriends: Int
    
    lazy var isCertified: Bool = {
        return contains(CertifiedManager.sharedInstance.certifiedUsers, self.objectId!)
    } ()
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

//    func getReceivedPleeks(withCache: Bool, skip: Int, completed: PleekCompletionHandler) {
//        var friendsObjects: [User] = []
//        self.getFriends(true).continueWithBlock { (task : BFTask!) -> AnyObject! in
//            
//            if task.error == nil{
//                friendsObjects = self.getListOfUserObjectFromJoinObject(task.result as! [Friend])
//            }
//
//            let autoFriend: [User] = friendsObjects.filter({ (user) -> Bool in
//                return (user.objectId! == self.objectId!)
//            })
//            
//            friendsObjects.removeObject(autoFriend.first!)
//            
//            var pleeksQuery = Pleek.query()!
//            
//            pleeksQuery.orderByDescending("lastUpdate")
//            pleeksQuery.includeKey("user")
//            pleeksQuery.whereKey("user", containedIn: friendsObjects)
//            pleeksQuery.whereKey("objectId", notContainedIn: self.pleeksHided)
//            
//            if withCache {
//                pleeksQuery.cachePolicy = PFCachePolicy.CacheThenNetwork
//            } else {
//                pleeksQuery.cachePolicy = PFCachePolicy.NetworkElseCache
//            }
//            
//            pleeksQuery.limit = Constants.LoadPleekLimit
//            pleeksQuery.skip = skip
//            
//            pleeksQuery.findObjectsInBackgroundWithBlock { (pleeks : [AnyObject]?, error : NSError?) -> Void in
//                completed(pleeks: pleeks as? [Pleek], error: error)
//            }
//            
//            return nil
//        }
//    }
    
    
    
    func getReceivedPleeks() -> (withCache: Bool, skip: Int, completed: PleekCompletionHandler) -> () {
        func local(withCache: Bool, skip: Int, completed: PleekCompletionHandler) {
            var friendsObjects: [User] = []
            self.getFriends(true).continueWithBlock { (task : BFTask!) -> AnyObject! in
                
                if task.error == nil{
                    friendsObjects = self.getListOfUserObjectFromJoinObject(task.result as! [Friend])
                }
                
                let autoFriend: [User] = friendsObjects.filter({ (user) -> Bool in
                    return (user.objectId! == self.objectId!)
                })
                
                friendsObjects.removeObject(autoFriend.first!)
                
                var pleeksQuery = Pleek.query()!
                
                pleeksQuery.orderByDescending("lastUpdate")
                pleeksQuery.includeKey("user")
                pleeksQuery.whereKey("user", containedIn: friendsObjects)
                pleeksQuery.whereKey("objectId", notContainedIn: self.pleeksHided)
                
                if withCache {
                    pleeksQuery.cachePolicy = PFCachePolicy.CacheThenNetwork
                } else {
                    pleeksQuery.cachePolicy = PFCachePolicy.NetworkElseCache
                }
                
                pleeksQuery.limit = Constants.LoadPleekLimit
                pleeksQuery.skip = skip
                
                pleeksQuery.findObjectsInBackgroundWithBlock { (pleeks : [AnyObject]?, error : NSError?) -> Void in
                    completed(pleeks: pleeks as? [Pleek], error: error)
                }
                
                return nil
            }
        }
        
        return local
    }

    func getSentPleeks() -> (withCache: Bool, skip: Int, completed: PleekCompletionHandler) -> () {
        
        func local(withCache: Bool, skip: Int, completed: PleekCompletionHandler) {
            
            var pleeksQuery = Pleek.query()!
            
            pleeksQuery.orderByDescending("lastUpdate")
            pleeksQuery.includeKey("user")
            pleeksQuery.whereKey("user", containedIn: [self])
            pleeksQuery.whereKey("objectId", notContainedIn: self.pleeksHided)
            
            if withCache {
                pleeksQuery.cachePolicy = PFCachePolicy.CacheThenNetwork
            } else {
                pleeksQuery.cachePolicy = PFCachePolicy.NetworkElseCache
            }
            
            pleeksQuery.limit = Constants.LoadPleekLimit
            pleeksQuery.skip = skip
            
            pleeksQuery.findObjectsInBackgroundWithBlock { (pleeks : [AnyObject]?, error : NSError?) -> Void in
                completed(pleeks: pleeks as? [Pleek], error: error)
            }
        }
        
        return local
    }
    
    
//    func getSentPleeks(withCache: Bool, skip: Int, completed: (pleeks: [Pleek]?, error: NSError?) -> ()) {
//        
//        var pleeksQuery = Pleek.query()!
//        
//        pleeksQuery.orderByDescending("lastUpdate")
//        pleeksQuery.includeKey("user")
//        pleeksQuery.whereKey("user", containedIn: [self])
//        pleeksQuery.whereKey("objectId", notContainedIn: self.pleeksHided)
//        
//        if withCache {
//            pleeksQuery.cachePolicy = PFCachePolicy.CacheThenNetwork
//        } else {
//            pleeksQuery.cachePolicy = PFCachePolicy.NetworkElseCache
//        }
//        
//        pleeksQuery.limit = Constants.LoadPleekLimit
//        pleeksQuery.skip = skip
//        
//        pleeksQuery.findObjectsInBackgroundWithBlock { (pleeks : [AnyObject]?, error : NSError?) -> Void in
//            completed(pleeks: pleeks as? [Pleek], error: error)
//        }
//    }
    
    func getFriends(withCache : Bool) -> BFTask {
        
        var friendsCompletionTask = BFTaskCompletionSource()
        var needToUpdateLocalFriendsList:Bool = false
        
        var queryFriends = Friend.query()!
        queryFriends.whereKey("user", equalTo: self)
        queryFriends.limit = Constants.LoadFriendLimit
        
        if withCache {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
            
            if appDelegate.friendsIdList.count == 0 {
                needToUpdateLocalFriendsList = true
            }
            
            if queryFriends.hasCachedResult() {
                queryFriends.cachePolicy = PFCachePolicy.CacheOnly
            } else{
                needToUpdateLocalFriendsList = true
                queryFriends.cachePolicy = PFCachePolicy.NetworkOnly
            }
        }
        else {
            needToUpdateLocalFriendsList = true
            queryFriends.cachePolicy = PFCachePolicy.NetworkOnly
        }
        
        queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
            
            if let error = error {
                friendsCompletionTask.setError(error)
            } else {
                self.updateLocalFriendsIdList(friends as! [Friend])
                friendsCompletionTask.setResult(friends)
            }
        }
        
        return friendsCompletionTask.task
    }

    func getListOfUserObjectFromJoinObject(friends : [Friend]) -> [User] {
        
        var friendsObjects: [User] = []
        var friendsId: [String] = []
        
        friends.map { friendsId.append($0.friendId) }
        friendsId.map { friendsObjects.append(User(withoutDataWithObjectId: $0)) }
        
        return friendsObjects
    }
    
    func updateLocalFriendsIdList(friends: [Friend]) {
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
        appDelegate.friendsIdList.removeAll(keepCapacity: false)
        friends.map { appDelegate.friendsIdList.append($0.friendId) }
    }
    
    func getTopFriends(withCache: Bool, skip: Int, completed: (friends: [Friend]?, error: NSError?) -> ()) {

        let topFriendsQuery: PFQuery = Friend.query()!
        topFriendsQuery.orderByDescending("score")
        topFriendsQuery.limit = 10
        topFriendsQuery.whereKey("user", equalTo: self)
        topFriendsQuery.includeKey("friend")
        if withCache {
            topFriendsQuery.cachePolicy = PFCachePolicy.CacheThenNetwork
        } else {
            topFriendsQuery.cachePolicy = PFCachePolicy.NetworkElseCache
        }
        
        topFriendsQuery.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
            completed(friends: friends as? [Friend], error: error)
        }
    }
    
    class func find(name: String) -> BFTask {
        let query = User.query()!
        
        query.whereKey("username", equalTo: name)
        query.cachePolicy = PFCachePolicy.NetworkElseCache
        
        return query.findObjectsInBackground()
    }
    
}