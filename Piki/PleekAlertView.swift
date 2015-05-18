//
//  PleekAlertView.swift
//  Peekee
//
//  Created by Kevin CATHALY on 18/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import UIKit

class PleekAlertView: NSObject, UIAlertViewDelegate {
    var firstAction: (() -> Void)?
    var secondAction: (() -> Void)?
    var title: String
    var message: String
    var firstButtonTitle: String
    var secondButtonTitle: String
    
    init(title: String, message: String, firstButtonTitle: String, secondButtonTitle: String, firstAction: (() -> Void)?, secondAction: (() -> Void)?) {
        self.title = title
        self.message = message
        self.firstButtonTitle = firstButtonTitle
        self.secondButtonTitle = secondButtonTitle
        self.firstAction = firstAction
        self.secondAction = secondAction
        
        super.init()
        
        if let gotModernAlert: AnyClass = NSClassFromString("UIAlertController") {
            self.presentAlertController()
        } else {
            self.presentAlertView()
        }
    }
    
    func presentAlertController() {
        var alert = UIAlertController(title: self.title, message: self.message, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: self.firstButtonTitle, style: .Default, handler: { (action) -> Void in
            if let firstAction = self.firstAction {
                firstAction()
            }
        }))
            
        alert.addAction(UIAlertAction(title: self.secondButtonTitle, style: .Default, handler: { (action) -> Void in
            if let secondAction = self.secondAction {
                secondAction()
            }
        }))
           
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func presentAlertView() {
        let alertView = UIAlertView(title: self.title, message: self.message, delegate: self, cancelButtonTitle: self.firstButtonTitle, otherButtonTitles: self.secondButtonTitle)
        alertView.alertViewStyle = .Default
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            if let firstAction = self.firstAction {
                firstAction()
            }
        } else {
            if let secondAction = self.secondAction {
                secondAction()
            }
        }
    }
}
