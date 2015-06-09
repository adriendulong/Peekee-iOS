//
//  Certified.swift
//  Peekee
//
//  Created by Kevin CATHALY on 12/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation

class Certified: PFObject, PFSubclassing {
    
    @NSManaged var isRecommend: NSNumber
    @NSManaged var user: User
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Certified"
    }
    
    class func getAllCertifiedUsers() -> [String] {
        var query = Certified.query()!
        query.limit = 30
        query.includeKey("user")
        let certified: [Certified] = query.findObjects() as? [Certified] ?? []
        var certifiedUsers: [String] = []
        var i = 0
        for cert: Certified in certified {
            if cert.isRecommend.boolValue {
                if let id = cert.user.objectId {
                    certifiedUsers.append(id)
                }
            }
        }
        
        return  certifiedUsers
    }
}

private let _SomeManagerSharedInstance = CertifiedManager()

class CertifiedManager {
    var certifiedUsers = Certified.getAllCertifiedUsers()
    static let sharedInstance = CertifiedManager()
}