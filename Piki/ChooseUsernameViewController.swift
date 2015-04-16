//
//  ChooseUsernameViewController.swift
//  Piki
//
//  Created by Adrien Dulong on 10/11/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation


class ChooseUsernameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bigTimeLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var chooseUsernameLabel: UILabel!
    
    var usernameView:UIView?

    var usernameTextField:UITextField?
    
    var notAvailableUsernameLabel:UILabel?
    var termsLabel:UILabel?
    
    var validationView:UIView?
    var keyboardSize:CGSize?
    var phoneNumber:String?
    var username:String?
    var usernameChoiceIndicator:UIImageView?
    var canSignUp:Bool = false
    
    @IBOutlet weak var spaceVerticalConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Mixpanel.sharedInstance().track("Choose Username View")
        
        if keyboardSize == nil{
            keyboardSize = CGSize(width: self.view.frame.width, height: 270)
        }
        
        if phoneNumber == nil{
            phoneNumber = "+33601010101"
        }
        
        
        if UIScreen.mainScreen().bounds.height < 500{
            spaceVerticalConstraint.constant = 0
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        self.view.backgroundColor = Utils().primaryColor
        
        statusView.backgroundColor = Utils().primaryColorDark
        containerView.backgroundColor = Utils().primaryColor
        separatorView.backgroundColor = Utils().secondColor
        
        bigTimeLabel.font = UIFont(name: Utils().customFontSemiBold, size: 20.0)
        bigTimeLabel.text = NSLocalizedString("Big time now.", comment : "Big time now.")
        
        chooseUsernameLabel.font = UIFont(name: Utils().customFontNormal, size: 18.0)
        chooseUsernameLabel.text =  NSLocalizedString("Choose a username", comment : "Choose a username")
        chooseUsernameLabel.textColor = UIColor(red: 121/255, green: 134/255, blue: 202/255, alpha: 1.0)

        
        var gestureGetStarted:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("getStarted:"))
        validationView = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height - keyboardSize!.height - 50, width: self.view.frame.size.width, height: 50))
        validationView!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        validationView!.addGestureRecognizer(gestureGetStarted)
        
        let labelGetStarted:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: validationView!.frame.width, height: validationView!.frame.height))
        labelGetStarted.font = UIFont(name: Utils().customFontSemiBold, size: 16.0)
        labelGetStarted.textColor = UIColor.whiteColor()
        labelGetStarted.textAlignment = NSTextAlignment.Center
        labelGetStarted.text = NSLocalizedString("LET'S GET STARTED", comment : "LET'S GET STARTED")
        validationView!.addSubview(labelGetStarted)

        var tapGestureTerms = UITapGestureRecognizer(target: self, action: Selector("openTerms"))
        termsLabel = UILabel(frame: CGRect(x: 0, y: validationView!.frame.origin.y - 25, width: self.view.frame.width, height: 15))
        termsLabel!.font = UIFont(name: Utils().customFontNormal, size: 14.0)
        termsLabel!.textAlignment = NSTextAlignment.Center
        termsLabel!.textColor = Utils().primaryColorDark
        termsLabel!.text = NSLocalizedString("You confirm you've read and accept T&C", comment : "You confirm you've read and accept T&C")
        termsLabel!.userInteractionEnabled = true
        termsLabel!.hidden = false
        termsLabel!.addGestureRecognizer(tapGestureTerms)
        self.view.addSubview(termsLabel!)
        
        notAvailableUsernameLabel = UILabel(frame: CGRect(x: 0, y: validationView!.frame.origin.y - 25, width: self.view.frame.width, height: 15))
        notAvailableUsernameLabel!.font = UIFont(name: Utils().customFontNormal, size: 14.0)
        notAvailableUsernameLabel!.textAlignment = NSTextAlignment.Center
        notAvailableUsernameLabel!.textColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        notAvailableUsernameLabel!.text = NSLocalizedString("The username is already taken. Try again.", comment : "The username is already taken. Try again.")
        notAvailableUsernameLabel!.adjustsFontSizeToFitWidth = true
        notAvailableUsernameLabel!.hidden = true
        self.view.addSubview(notAvailableUsernameLabel!)
        
        
        usernameView = UIView(frame: CGRect(x: 30, y: validationView!.frame.origin.y - 36 - 60, width: self.view.frame.width - 60, height: 53))
        usernameView!.backgroundColor = UIColor.clearColor()
        self.view.addSubview(usernameView!)
        
        let usernameLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: 14))
        usernameLabel.font = UIFont(name: Utils().customFontNormal, size: 12.0)
        usernameLabel.textColor = UIColor.whiteColor()
        usernameLabel.text = NSLocalizedString("USERNAME", comment : "USERNAME")
        usernameView!.addSubview(usernameLabel)
        
        let sublineTextFIeld:UIView = UIView(frame: CGRect(x: 0, y: usernameView!.frame.height - 1, width: usernameView!.frame.width, height: 1))
        sublineTextFIeld.backgroundColor = UIColor.whiteColor()
        usernameView!.addSubview(sublineTextFIeld)
        
        usernameTextField = UITextField(frame: CGRect(x: 0, y: usernameLabel.frame.height, width: usernameView!.frame.width - 20, height: usernameView!.frame.height - usernameLabel.frame.height - 2))
        usernameTextField!.font = UIFont(name: Utils().customFontSemiBold, size: 25.0)
        usernameTextField!.textColor = UIColor.whiteColor()
        usernameTextField!.backgroundColor = Utils().primaryColor
        usernameTextField!.tintColor = Utils().secondColor
        usernameTextField!.delegate = self
        usernameTextField!.leftViewMode = UITextFieldViewMode.Always
        usernameTextField!.autocorrectionType = UITextAutocorrectionType.No
        usernameTextField!.autocapitalizationType = UITextAutocapitalizationType.None
        usernameView!.addSubview(usernameTextField!)
        
        
        let leftViewTextField:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: usernameTextField!.frame.height))
        leftViewTextField.backgroundColor = Utils().primaryColor
        usernameTextField!.leftView = leftViewTextField
        
        let labelLeftTextField:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: leftViewTextField.frame.width, height: leftViewTextField.frame.height))
        labelLeftTextField.font = usernameTextField!.font
        labelLeftTextField.textColor = UIColor.whiteColor()
        labelLeftTextField.textAlignment = NSTextAlignment.Center
        labelLeftTextField.text = "@"
        leftViewTextField.addSubview(labelLeftTextField)
        
        usernameChoiceIndicator = UIImageView(frame: CGRect(x: usernameView!.frame.width - 20, y: 0, width: 20, height: usernameView!.frame.height))
        usernameChoiceIndicator!.contentMode = UIViewContentMode.Center
        usernameChoiceIndicator!.image = UIImage(named: "error_username_icon")
        usernameChoiceIndicator!.hidden = true
        usernameView!.addSubview(usernameChoiceIndicator!)
        
        
        usernameTextField!.becomeFirstResponder()
        
        self.view.addSubview(validationView!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var shouldReplace = true
        
        
        if isForbidden(string){
            return false
        }
        
        
        
        notAvailableUsernameLabel!.text = NSLocalizedString("The username is already taken. Try again.", comment : "The username is already taken. Try again.")
        usernameChoiceIndicator!.hidden = true
        
        var finalText:NSString = textField.text as NSString
        finalText = finalText.stringByReplacingCharactersInRange(range, withString: string)
        
        if finalText.length > 15{
            return false
        }
        
        
        var finalString:String = finalText as String!
        
        //Verify if exists
        if count(finalString) > 3 {
            println("Username : \(finalString)")
            if Utils().usernameValid(finalString){
                var userQuery:PFQuery = PFUser.query()!
                userQuery.whereKey("username", equalTo: finalString.lowercaseString)
                userQuery.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
                    if error == nil {
                        
                        //Username already exists
                        if users!.count > 0{
                            if textField.text == self.usernameTextField!.text{
                                self.usernameChoiceIndicator!.hidden = false
                                self.usernameChoiceIndicator!.image = UIImage(named: "error_username_icon")
                                self.validationView!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
                                self.canSignUp = false
                                self.notAvailableUsernameLabel!.hidden = false
                                self.termsLabel!.hidden = true
                            }
                        }
                        else{
                            if textField.text == self.usernameTextField!.text{
                                self.usernameChoiceIndicator!.hidden = false
                                self.usernameChoiceIndicator!.image = UIImage(named: "validated_username_icon")
                                self.validationView!.backgroundColor = Utils().secondColor
                                self.notAvailableUsernameLabel!.hidden = true
                                self.canSignUp = true
                                self.termsLabel!.hidden = false
                            }
                        }
                        
                    }
                    else{
                        if textField.text == self.usernameTextField!.text{
                            self.usernameChoiceIndicator!.hidden = false
                            self.usernameChoiceIndicator!.image = UIImage(named: "validated_username_icon")
                            self.validationView!.backgroundColor = Utils().secondColor
                            self.notAvailableUsernameLabel!.hidden = true
                            self.canSignUp = true
                            self.termsLabel!.hidden = false
                        }
                    }
                })
            }
            else{
                self.usernameChoiceIndicator!.hidden = false
                self.usernameChoiceIndicator!.image = UIImage(named: "error_username_icon")
                self.validationView!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
                self.notAvailableUsernameLabel!.hidden = false
                self.termsLabel!.hidden = true
                notAvailableUsernameLabel!.text = NSLocalizedString("The username is not valid : only letters and numbers allowed", comment : "The username is not valid : only letters and numbers allowed")
            }
            
            
        }
        else{
            self.usernameChoiceIndicator!.hidden = false
            self.usernameChoiceIndicator!.image = UIImage(named: "error_username_icon")
            self.notAvailableUsernameLabel!.hidden = false
            self.termsLabel!.hidden = true
            self.canSignUp = false
            self.validationView!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        }
        
        
        
        
        
        
        return shouldReplace
    }
    
    func getStarted(sender : UITapGestureRecognizer){
        var textFieldString = NSString(string: usernameTextField!.text)
        
        if Utils().usernameValid(textFieldString.lowercaseString){
            //Create User Object
            var user:PFUser = PFUser()
            
            user.username = textFieldString.lowercaseString
            user.password = textFieldString.lowercaseString
            
            var userInfos:PFObject = PFObject(className: "UserInfos")
            userInfos["phoneNumber"] = self.phoneNumber!
            
            user["userInfos"] = userInfos
            var usersFriend = [String]()
            user["usersFriend"] = usersFriend
            user["hasSeenRecommanded"] = false
            user["hasShownOverlayMenu"] = false
            user["hasShownOverlayPeekee"] = false
            user["hasSeenFriends"] = false
            
            
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            user.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
                if error != nil {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    if Utils().iOS8{
                        var alert = UIAlertController(title: NSLocalizedString("Error", comment : "Error"),
                            message: NSLocalizedString("Sorry an error occured. Please try again later", comment : "Sorry an error occured. Please try again later"), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    else{
                        var alertView = UIAlertView(title: NSLocalizedString("Error", comment : "Error"),
                            message: NSLocalizedString("Sorry an error occured. Please try again later", comment : "Sorry an error occured. Please try again later"),
                            delegate: nil,
                            cancelButtonTitle: "Ok")
                        alertView.show()
                    }
                    
                }
                else{
                    
                    var userInfos:PFObject = user["userInfos"] as! PFObject
                    userInfos.ACL = PFACL(user: user)
                    userInfos.saveEventually()
                    
                    
                    
                    Mixpanel.sharedInstance().createAlias(PFUser.currentUser()!.objectId!, forDistinctID: Mixpanel.sharedInstance().distinctId)
                    if user.username != nil{
                        Mixpanel.sharedInstance().people.set(["Username" : user.username!])
                    }
                    
                    if self.phoneNumber != nil{
                        Mixpanel.sharedInstance().people.set(["$phone" : self.phoneNumber!])
                    }
                    
                    
                    PFCloud.callFunctionInBackground("addToFirstUsePiki",
                        withParameters: ["Test" : "Test"],
                        block: { (result, error) -> Void in

                            Utils().updateUser().continueWithBlock({ (task : BFTask!) -> AnyObject! in
                                FBSDKAppEvents.logEvent(FBSDKAppEventNameCompletedRegistration)
                                Mixpanel.sharedInstance().track("Sign Up")
                                
                                MBProgressHUD.hideHUDForView(self.view, animated: true)
                                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.window?.rootViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! UINavigationController
                                
                                return nil
                            })

                            
                    })
                    
                    
                    /*
                    user.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                        if error == nil {
                            
                            
                            
                            
                        }
                        else{
                            user.saveEventually()
                            
                            if Utils().iOS8{
                                var alert = UIAlertController(title: NSLocalizedString("Error", comment : "Error"),
                                    message: NSLocalizedString("We had a problem while connecting you with your phone number, please try again later", comment : "We had a problem while connecting you with your phone number, please try again later"), preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                            else{
                                var alertView = UIAlertView(title: NSLocalizedString("Error", comment : "Error"),
                                    message: NSLocalizedString("We had a problem while connecting you with your phone number, please try again later", comment : "We had a problem while connecting you with your phone number, please try again later"),
                                    delegate: nil,
                                    cancelButtonTitle: "Ok")
                                alertView.show()
                            }
                            
                        }
                        
                        
                    })*/
                }
            }
        }
        else{
            if Utils().iOS8{
                var alert = UIAlertController(title: NSLocalizedString("Error", comment : "Error"),
                    message: NSLocalizedString("The username is not valid : only letters and numbers allowed", comment : "The username is not valid : only letters and numbers allowed"), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else{
                var alertView = UIAlertView(title: NSLocalizedString("Error", comment : "Error"),
                    message: NSLocalizedString("The username is not valid : only letters and numbers allowed", comment : "The username is not valid : only letters and numbers allowed"),
                    delegate: nil,
                    cancelButtonTitle: "Ok")
                alertView.show()
            }
        }
        
        
        
    }
    
    
    func keyboardWillShow(notification : NSNotification){
        
        let info:NSDictionary = notification.userInfo!
        let kbSize:CGSize = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue().size
        
        validationView!.frame = CGRect(x: 0, y: self.view.frame.size.height - kbSize.height - 55, width: self.view.frame.size.width, height: 55)
        usernameView!.frame = CGRect(x: 15, y: validationView!.frame.origin.y - 36 - 53, width: self.view.frame.width - 30, height: 53)
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
    // MARK : Forbidden characters for username
    
    func isForbidden(string : String) -> Bool{
        
        let forbiddenCharacters : Array<String> = ["@", " ", "/", "!", "#"]
        
        if contains(forbiddenCharacters, string){
            return true
        }
        else{
          return false
        }
    }
    
    
    // MARK: Open Terms
    
    func openTerms(){
        
        UIApplication.sharedApplication().openURL(NSURL(string: "http://pleekapp.com/terms")!)
        
    }
    
    

    
}