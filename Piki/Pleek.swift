//
//  Pleek.swift
//  Peekee
//
//  Created by Kevin CATHALY on 11/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation
    
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
    
    var react: [React] = []
    
    var nbNewReaction: Int {
        if let infos = self.infos, let nbReactions = infos["nbReaction"] as? Int  {
            return nbReactions - self.nbReaction
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
}