//
//  VerificationCodePhoneViewController.swift
//  Piki
//
//  Created by Adrien Dulong on 10/11/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation


class VerificationCodePhoneViewController: UIViewController, UITextFieldDelegate {
    
    var verificationCode:String?
    var phoneNumber:String?
    var keyboardSize:CGSize?
    var username:String?
    var regionCode:String?
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var verticalSpaceConstraint: NSLayoutConstraint!
    var phoneFormatter:NBAsYouTypeFormatter?
    
    var validationView:UIView?
    
    var codeTextFieldOne:UITextField?
    var codeTextFieldTwo:UITextField?
    var codeTextFieldThree:UITextField?
    var codeTextFieldFour:UITextField?
    
    var invalidCodeLabel:UILabel?
    
    @IBOutlet weak var codeSentLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIScreen.mainScreen().bounds.height < 500{
            verticalSpaceConstraint.constant = 0
        }
        
        confirmationCodeTextField.hidden = true
        //Notifs when keyboard whox or hide
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        println("Verification code is \(verificationCode) for number \(phoneNumber)")
        
        phoneFormatter = NBAsYouTypeFormatter(regionCode: self.regionCode!)
        
        
        self.view.backgroundColor = Utils().primaryColor
        
        codeSentLabel.font = UIFont(name: Utils().customFontSemiBold, size: 20.0)
        codeSentLabel.text = NSLocalizedString("Code sent.", comment : "Code sent.")
        
        separatorView.backgroundColor = Utils().secondColor
        
        phoneNumberLabel.font = UIFont(name: Utils().customFontNormal, size: 16.0)
        phoneNumberLabel.text = phoneFormatter!.inputDigit(phoneNumber)
        phoneNumberLabel.textColor = UIColor(red: 121/255, green: 134/255, blue: 202/255, alpha: 1.0)
        
        containerView.backgroundColor = Utils().primaryColor
        
        statusView.backgroundColor = Utils().primaryColorDark
        
        var gestureCheckNumber:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("checkNumber:"))
        validationView = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height - keyboardSize!.height - 55, width: self.view.frame.size.width, height: 55))
        validationView!.backgroundColor = Utils().primaryColorDark
        validationView!.addGestureRecognizer(gestureCheckNumber)
        self.view.addSubview(validationView!)
        
        let checkNumberLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: validationView!.frame.width, height: validationView!.frame.height))
        checkNumberLabel.font = UIFont(name: Utils().customFontSemiBold, size: 16.0)
        checkNumberLabel.textColor = UIColor.whiteColor()
        checkNumberLabel.textAlignment = NSTextAlignment.Center
        checkNumberLabel.adjustsFontSizeToFitWidth = true
        checkNumberLabel.text = NSLocalizedString("CHECK MY CELL NUMBER", comment : "CHECK MY CELL NUMBER")
        validationView!.addSubview(checkNumberLabel)
        
        let previousIcon:UIImageView = UIImageView(frame: CGRect(x: 15, y: 0, width: 8, height: validationView!.frame.height))
        previousIcon.contentMode = UIViewContentMode.Center
        previousIcon.image = UIImage(named: "previous_icon")
        validationView!.addSubview(previousIcon)
        
        
        
        //LABEL IF ERROR IN 4 DIGIT CODE
        invalidCodeLabel = UILabel(frame: CGRect(x: 0, y: validationView!.frame.origin.y - 25, width: self.view.frame.width, height: 15))
        invalidCodeLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 14.0)
        invalidCodeLabel!.textAlignment = NSTextAlignment.Center
        invalidCodeLabel!.textColor = Utils().secondColor
        invalidCodeLabel!.text = NSLocalizedString("Invalid code. Try again or check your phone number.", comment : "Invalid code. Try again or check your phone number.")
        invalidCodeLabel!.hidden = true
        invalidCodeLabel!.adjustsFontSizeToFitWidth = true
        self.view.addSubview(invalidCodeLabel!)
        
        
        
        //ENTER THE 4 DIGIT CODE
        let codeEnterView:UIView = UIView(frame: CGRect(x: 15, y: validationView!.frame.origin.y - 80, width: 260, height: 52))
        codeEnterView.center = CGPoint(x: self.view.frame.width/2, y: validationView!.frame.origin.y - 54)
        codeEnterView.backgroundColor = Utils().primaryColor
        self.view.addSubview(codeEnterView)
        
        let codeLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 10))
        codeLabel.font = UIFont(name: Utils().customFontNormal, size: 10.0)
        codeLabel.textColor = UIColor.whiteColor()
        codeLabel.text = "CODE"
        codeEnterView.addSubview(codeLabel)
        
        
        //UNDERLINES TEXT FIELD CODE
        let sublineOne:UIView = UIView(frame: CGRect(x: 0, y: codeEnterView.frame.height - 1, width: 47, height: 1))
        sublineOne.backgroundColor = UIColor.whiteColor()
        codeEnterView.addSubview(sublineOne)
        
        let sublineTwo:UIView = UIView(frame: CGRect(x: sublineOne.frame.origin.x + sublineOne.frame.width + 24, y: codeEnterView.frame.height - 1, width: 47, height: 1))
        sublineTwo.backgroundColor = UIColor.whiteColor()
        codeEnterView.addSubview(sublineTwo)
        
        let sublineThree:UIView = UIView(frame: CGRect(x: sublineTwo.frame.origin.x + sublineTwo.frame.width + 24, y: codeEnterView.frame.height - 1, width: 47, height: 1))
        sublineThree.backgroundColor = UIColor.whiteColor()
        codeEnterView.addSubview(sublineThree)
        
        let sublineFour:UIView = UIView(frame: CGRect(x: sublineThree.frame.origin.x + sublineThree.frame.width + 24, y: codeEnterView.frame.height - 1, width: 47, height: 1))
        sublineFour.backgroundColor = UIColor.whiteColor()
        codeEnterView.addSubview(sublineFour)
        
        //TEXTFIELDS
        codeTextFieldOne = UITextField(frame: CGRect(x: 0, y: 0, width: 47, height: codeEnterView.frame.height - 1))
        codeTextFieldOne!.font = UIFont(name: Utils().customFontSemiBold, size: 30)
        codeTextFieldOne!.textColor = UIColor.whiteColor()
        codeTextFieldOne!.backgroundColor = Utils().primaryColor
        codeTextFieldOne!.textAlignment = NSTextAlignment.Center
        codeTextFieldOne!.tintColor = Utils().secondColor
        codeTextFieldOne!.keyboardType = UIKeyboardType.NumberPad
        codeTextFieldOne!.delegate = self
        codeEnterView.addSubview(codeTextFieldOne!)
        
        codeTextFieldTwo = UITextField(frame: CGRect(x: codeTextFieldOne!.frame.origin.x + codeTextFieldOne!.frame.width + 24, y: 0, width: 47, height: codeEnterView.frame.height - 1))
        codeTextFieldTwo!.font = UIFont(name: Utils().customFontSemiBold, size: 30)
        codeTextFieldTwo!.textColor = UIColor.whiteColor()
        codeTextFieldTwo!.backgroundColor = Utils().primaryColor
        codeTextFieldTwo!.textAlignment = NSTextAlignment.Center
        codeTextFieldTwo!.tintColor = Utils().secondColor
        codeTextFieldTwo!.keyboardType = UIKeyboardType.NumberPad
        codeTextFieldTwo!.delegate = self
        codeEnterView.addSubview(codeTextFieldTwo!)
        
        codeTextFieldThree = UITextField(frame: CGRect(x: codeTextFieldTwo!.frame.origin.x + codeTextFieldTwo!.frame.width + 24, y: 0, width: 47, height: codeEnterView.frame.height - 1))
        codeTextFieldThree!.font = UIFont(name: Utils().customFontSemiBold, size: 30)
        codeTextFieldThree!.textColor = UIColor.whiteColor()
        codeTextFieldThree!.backgroundColor = Utils().primaryColor
        codeTextFieldThree!.textAlignment = NSTextAlignment.Center
        codeTextFieldThree!.tintColor = Utils().secondColor
        codeTextFieldThree!.keyboardType = UIKeyboardType.NumberPad
        codeTextFieldThree!.delegate = self
        codeEnterView.addSubview(codeTextFieldThree!)
        
        codeTextFieldFour = UITextField(frame: CGRect(x: codeTextFieldThree!.frame.origin.x + codeTextFieldThree!.frame.width + 24, y: 0, width: 47, height: codeEnterView.frame.height - 1))
        codeTextFieldFour!.font = UIFont(name: Utils().customFontSemiBold, size: 30)
        codeTextFieldFour!.textColor = UIColor.whiteColor()
        codeTextFieldFour!.backgroundColor = Utils().primaryColor
        codeTextFieldFour!.textAlignment = NSTextAlignment.Center
        codeTextFieldFour!.tintColor = Utils().secondColor
        codeTextFieldFour!.keyboardType = UIKeyboardType.NumberPad
        codeTextFieldFour!.delegate = self
        codeEnterView.addSubview(codeTextFieldFour!)

        codeTextFieldOne!.becomeFirstResponder()
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    
    func modifyNumber(sender : UIButton){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        invalidCodeLabel!.hidden = true
        validationView!.backgroundColor = Utils().primaryColorDark
        
        var codeEntered:NSString = textField.text as NSString
        codeEntered = codeEntered.stringByReplacingCharactersInRange(range, withString: string)

        
        if codeEntered.length > (textField.text as NSString).length{
            if codeEntered.length > 1{
                codeEntered = codeEntered.substringFromIndex(1)
            }
            
            
            if textField == codeTextFieldOne{
                codeTextFieldOne!.text = codeEntered
                codeTextFieldTwo!.becomeFirstResponder()
                
                return false
            }
            else if textField == codeTextFieldTwo{
                codeTextFieldTwo!.text = codeEntered
                codeTextFieldThree!.becomeFirstResponder()
                
                return false
            }
            else if textField == codeTextFieldThree{
                codeTextFieldThree!.text = codeEntered
                codeTextFieldFour!.becomeFirstResponder()
                
                return false
            }
            else{
                codeTextFieldFour!.text = codeEntered
                var codeString = codeTextFieldOne!.text + codeTextFieldTwo!.text + codeTextFieldThree!.text + codeTextFieldFour!.text
                println("Validate Code : \(codeString)")
                
                
                if codeString == self.verificationCode{

                    //If we have a username, the account already exists we connect the user
                    if self.username != nil {
                        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                        PFUser.logInWithUsernameInBackground(self.username, password: self.username, block: { (user , error) -> Void in
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            if error != nil {
                                println("Error : \(error.localizedDescription)")
                                var alert = UIAlertController(title:NSLocalizedString("Error", comment : "Error") ,
                                    message: NSLocalizedString("We had a problem while connecting you with your phone number, please try again later", comment : "We had a problem while connecting you with your phone number, please try again later"), preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                            else{
                                
                                
                                //Associate the user in Mixpanel
                                Mixpanel.sharedInstance().identify(PFUser.currentUser().objectId)
                                if self.phoneNumber != nil{
                                    Mixpanel.sharedInstance().people.set(["$phone" : self.phoneNumber!])
                                }
                                Mixpanel.sharedInstance().track("Log In")
                                
                                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                                appDelegate.window?.rootViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as UINavigationController
                            }
                        })
                    }
                        //Else he has to choose a username
                    else{
                        self.performSegueWithIdentifier("chooseUsername", sender: self)
                    }
                    
                    
                    
                    
                }
                else {
                    invalidCodeLabel!.hidden = false
                    validationView!.backgroundColor = Utils().secondColor
                    
                }
                
                return false
            }
            
            
        }
        else{
            if textField == codeTextFieldOne{
                codeTextFieldOne!.text = ""
                return false

            }
            else if textField == codeTextFieldTwo{
                codeTextFieldTwo!.text = ""
                codeTextFieldOne!.becomeFirstResponder()
                return false
            }
            else if textField == codeTextFieldThree{
                codeTextFieldThree!.text = ""
                codeTextFieldTwo!.becomeFirstResponder()
                return false
            }
            else{
                codeTextFieldFour!.text = ""
                codeTextFieldThree!.becomeFirstResponder()
                return false
            }
        }
        
        //return true
        
        
    }
    
    
    //Keyboard Notifs
    func keyboardWillShow(notification : NSNotification){
        
        let info:NSDictionary = notification.userInfo!
        let kbSize:CGSize = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue().size
        
        validationView!.frame = CGRect(x: 0, y: self.view.frame.size.height - kbSize.height - 55, width: self.view.frame.size.width, height: 55)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chooseUsername"{
            
            var nextController:ChooseUsernameViewController = segue.destinationViewController as ChooseUsernameViewController
            nextController.keyboardSize = self.keyboardSize
            nextController.phoneNumber = self.phoneNumber
            
            if username != nil {
                nextController.username = username
            }
            
        }
    }
    
    func checkNumber(tapgesture : UITapGestureRecognizer){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}