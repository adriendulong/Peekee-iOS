//
//  PhoneNumberViewController.swift
//  Piki
//
//  Created by Adrien Dulong on 10/11/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import CoreTelephony
//import UIKit
import AVFoundation



class PhoneNumberViewController: UIViewController, UITextFieldDelegate, CountriesControllerProtocol {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var phoneContainerView: UIView!
    @IBOutlet weak var noBotsLabel: UILabel!
    @IBOutlet weak var enterPhoneLabel: UILabel!
    
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var daftImageView: UIImageView!
    
    @IBOutlet weak var verticalSpaceConstraint: NSLayoutConstraint!
    
    
    var phoneNumberIndicator:UILabel?
    //var phoneNumberTextField:UITextField?
    var validatePhoneView:UIView?
    var keyboardSize:CGSize?
    
    var phoneNumberView:UIView?
    var phoneIndicatorActionView:UIView?
    var countryLabel:UILabel?
    var indicatorLabel:UILabel?
    var phoneNumberActionView:UIView?
    var phoneNumberTextField:UITextField?
    
    var phoneFormatter:NBAsYouTypeFormatter?
    
    
    var harderPlayer: AVAudioPlayer?
    var betterPlayer: AVAudioPlayer?
    var fasterPlayer: AVAudioPlayer?
    var strongerPlayer: AVAudioPlayer?
    
    var diallingCodesDictionary:NSDictionary?
    var regionLabel:String?
    var countriesInfos:Array<[String : String]> = Array<[String : String]>()
    var verificationCode:String?
    var finalFormatedNumber:String?
    var username:String?
    
    var phoneNumberValid:Bool = false
    
    var incrementPlayer:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Mixpanel.sharedInstance().track("Phone Number View")
        
        if UIScreen.mainScreen().bounds.height < 500{
            verticalSpaceConstraint.constant = 0
        }
        
        //Button to validate phone number
        var gestureSendCode:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("sendConfCode:"))
        validatePhoneView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 55, width: self.view.frame.size.width, height: 55))
        validatePhoneView!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        validatePhoneView!.addGestureRecognizer(gestureSendCode)
        self.view.addSubview(validatePhoneView!)
        
        let textValidatePhone:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: validatePhoneView!.frame.width, height: validatePhoneView!.frame.height))
        textValidatePhone.font = UIFont(name: Utils().customFontSemiBold, size: 16.0)
        textValidatePhone.textColor = UIColor.whiteColor()
        textValidatePhone.textAlignment = NSTextAlignment.Center
        textValidatePhone.adjustsFontSizeToFitWidth = true
        textValidatePhone.text = NSLocalizedString("TEXT ME A 4 DIGITS CODE", comment : "TEXT ME A 4 DIGITS CODE")
        validatePhoneView!.addSubview(textValidatePhone)
        
        let iconSendImageView:UIImageView = UIImageView(frame: CGRect(x: validatePhoneView!.frame.width - 30 - 25, y: 0, width: 25, height: validatePhoneView!.frame.height))
        iconSendImageView.contentMode = UIViewContentMode.Center
        iconSendImageView.image = UIImage(named: "send_icon")
        validatePhoneView!.addSubview(iconSendImageView)
        
        
        
        var gestureDaft:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("daftAnim:"))
        daftImageView!.userInteractionEnabled = true
        daftImageView!.addGestureRecognizer(gestureDaft)
        
        statusBar.backgroundColor = Utils().primaryColorDark
        self.view.backgroundColor = Utils().primaryColor
        contentView.backgroundColor = Utils().primaryColor
        separatorView.backgroundColor = Utils().secondColor
        
        noBotsLabel.font = UIFont(name: Utils().customFontSemiBold, size: 24.0)
        noBotsLabel.textColor = UIColor.whiteColor()
        noBotsLabel.text = NSLocalizedString("No bots allowed.", comment : "No bots allowed.")
        
        enterPhoneLabel.font = UIFont(name: Utils().customFontSemiBold, size: 20.0)
        enterPhoneLabel.textColor = Utils().primaryColorDark
        enterPhoneLabel.text = NSLocalizedString("Enter your cell number", comment : "Enter your cell number")
        
        phoneNumberView = UIView(frame: CGRect(x: 30, y: validatePhoneView!.frame.origin.y - 53 - 20, width: self.view.frame.width - 60, height: 53))
        phoneNumberView!.backgroundColor = UIColor.clearColor()
        self.view.addSubview(phoneNumberView!)
        
        var gestureNumberChoose:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("chooseNumberAction:"))
        phoneIndicatorActionView = UIView(frame: CGRect(x: 0, y: 0, width: 65, height: phoneNumberView!.frame.height))
        phoneIndicatorActionView!.backgroundColor = UIColor.clearColor()
        phoneIndicatorActionView!.addGestureRecognizer(gestureNumberChoose)
        phoneNumberView!.addSubview(phoneIndicatorActionView!)
        
        countryLabel = UILabel(frame: CGRect(x: 0, y: 0, width: phoneIndicatorActionView!.frame.width, height: 10))
        countryLabel!.font = UIFont(name: Utils().customFontNormal, size: 10)
        countryLabel!.textColor = UIColor.whiteColor()
        countryLabel!.text = NSLocalizedString("Unknown", comment : "Unknown")
        phoneIndicatorActionView!.addSubview(countryLabel!)
        
        indicatorLabel = UILabel(frame: CGRect(x: 0, y: 10, width: phoneIndicatorActionView!.frame.width - 15, height: phoneIndicatorActionView!.frame.height - 12))
        indicatorLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 20)
        indicatorLabel!.textColor = UIColor.whiteColor()
        indicatorLabel!.text = "+??"
        phoneNumberView!.addSubview(indicatorLabel!)
        
        let underBarCountry:UIView = UIView(frame: CGRect(x: 0, y: phoneIndicatorActionView!.frame.height - 1, width: phoneIndicatorActionView!.frame.width, height: 1))
        underBarCountry.backgroundColor = UIColor.whiteColor()
        phoneNumberView!.addSubview(underBarCountry)
        
        
        phoneNumberActionView = UIView(frame: CGRect(x: phoneIndicatorActionView!.frame.width + 20, y: 0, width: phoneNumberView!.frame.width - 20 - phoneIndicatorActionView!.frame.width, height: phoneNumberView!.frame.height))
        phoneNumberActionView!.backgroundColor = UIColor.clearColor()
        
        phoneNumberView!.addSubview(phoneNumberActionView!)
        
        phoneNumberTextField = UITextField(frame: CGRect(x: 0, y: 0, width: phoneNumberActionView!.frame.width, height: phoneNumberActionView!.frame.height - 1))
        phoneNumberTextField!.font = UIFont(name: Utils().customFontSemiBold, size: 20.0)
        phoneNumberTextField!.backgroundColor = Utils().primaryColor
        phoneNumberTextField!.textColor = UIColor.whiteColor()
        phoneNumberTextField!.placeholder = NSLocalizedString("Phone", comment : "Phone")
        phoneNumberTextField!.delegate = self
        phoneNumberTextField!.tintColor = Utils().secondColor
        phoneNumberTextField!.adjustsFontSizeToFitWidth = true
        phoneNumberTextField!.keyboardType = UIKeyboardType.PhonePad
        phoneNumberActionView!.addSubview(phoneNumberTextField!)
        
        let underBarPhoneNumber:UIView = UIView(frame: CGRect(x: 0, y: phoneNumberActionView!.frame.height - 1, width: phoneNumberActionView!.frame.width, height: 1))
        underBarPhoneNumber.backgroundColor = UIColor.whiteColor()
        phoneNumberActionView!.addSubview(underBarPhoneNumber)
        
        //Notifs when keyboard whox or hide
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        
        //Build text field for phone number and display for country indicator
        phoneNumberIndicator = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width/4, height: 50))
        phoneNumberIndicator!.font = UIFont(name: "HelveticaNeue", size: 22)
        phoneNumberIndicator!.textColor = UIColor.whiteColor()
        phoneNumberIndicator!.textAlignment = NSTextAlignment.Center
        phoneNumberIndicator!.text = "+31"
        phoneContainerView.addSubview(phoneNumberIndicator!)
        
        /*phoneNumberTextField = UITextField(frame: CGRect(x: self.view.frame.size.width/4, y: 0, width: self.view.frame.size.width/4 * 3, height: 50))
        phoneNumberTextField!.delegate = self
        phoneNumberTextField!.font = UIFont(name: "HelveticaNeue", size: 22)
        phoneNumberTextField!.textColor = UIColor.whiteColor()
        phoneNumberTextField!.placeholder = "Your Phone Number"
        phoneNumberTextField!.keyboardType = UIKeyboardType.NumberPad
        phoneNumberTextField!.textAlignment = NSTextAlignment.Center
        phoneNumberTextField!.becomeFirstResponder()
        phoneContainerView.addSubview(phoneNumberTextField!)*/
        
        
        
        
        //Import list of countries
        //Dictionnay of country codes
        let plistPath:String = NSBundle.mainBundle().pathForResource("DiallingCodes", ofType: "plist")!
        diallingCodesDictionary = NSDictionary(contentsOfFile: plistPath)
        
        //Build array with dictionnaries of countries infos
        diallingCodesDictionary!.enumerateKeysAndObjectsUsingBlock { (key, object, stop) -> Void in
            
            var countryInfosDic = [String : String]()
            
            countryInfosDic["countryLetters"] = key as? String
            countryInfosDic["countryCode"] = object as? String
            
            if NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: key) != nil {
                countryInfosDic["countryName"] = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: key)!
            }
            else{
                countryInfosDic["countryName"] = LocalizedString("Unkwown")
            }
            
            self.countriesInfos.append(countryInfosDic)
        }
        //Sort the array
        self.countriesInfos.sort({ $0["countryName"] < $1["countryName"]})
        
        
        var test:String?
        
        if regionLabel != nil {
            println("test not nil")
        }
        else{
            println("test nil")
        }
        
        
        
        //NetworkInfos
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        
        if carrier != nil {
            
            regionLabel = carrier.isoCountryCode
            
            if regionLabel != nil {
                let country:String? = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value:regionLabel!)
                
                if country != nil{
                    countryButton.setTitle(country, forState: UIControlState.Normal)
                    
                    //Set the country code
                    for countryInfo in countriesInfos{
                        
                        if countryInfo["countryLetters"] == self.regionLabel{
                            let countryNumbers:String = countryInfo["countryCode"]!
                            phoneNumberIndicator!.text = "+\(countryNumbers)"
                            indicatorLabel!.text = "+\(countryNumbers)"
                            countryLabel!.text = countryInfo["countryName"]! as String
                        }
                        
                    }
                }
                else{
                    for countryInfo in countriesInfos{
                        self.regionLabel = "us"
                        if countryInfo["countryLetters"] == "us"{
                            countryButton.setTitle(countryInfo["countryName"], forState: UIControlState.Normal)
                            let countryNumbers:String = countryInfo["countryCode"]!
                            phoneNumberIndicator!.text = "+\(countryNumbers)"
                            
                            indicatorLabel!.text = "+\(countryNumbers)"
                            countryLabel!.text = countryInfo["countryName"]! as String
                        }
                        
                    }
                }
            }
            else{
                for countryInfo in countriesInfos{
                    self.regionLabel = "us"
                    if countryInfo["countryLetters"] == "us"{
                        countryButton.setTitle(countryInfo["countryName"], forState: UIControlState.Normal)
                        let countryNumbers:String = countryInfo["countryCode"]!
                        phoneNumberIndicator!.text = "+\(countryNumbers)"
                        
                        indicatorLabel!.text = "+\(countryNumbers)"
                        countryLabel!.text = countryInfo["countryName"]! as String
                    }
                    
                }
            }
            

        }
        else{
            
            //Set the country code
            for countryInfo in countriesInfos{
                self.regionLabel = "us"
                if countryInfo["countryLetters"] == "us"{
                    countryButton.setTitle(countryInfo["countryName"], forState: UIControlState.Normal)
                    let countryNumbers:String = countryInfo["countryCode"]!
                    phoneNumberIndicator!.text = "+\(countryNumbers)"
                }
                
            }
            
            
        }
        
        
        phoneFormatter = NBAsYouTypeFormatter(regionCode: self.regionLabel!)
        
        
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        phoneNumberTextField!.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        phoneNumberTextField!.becomeFirstResponder()
        
        let daftPath = NSBundle.mainBundle().pathForResource("harder", ofType: "wav")
        let daftURL = NSURL(fileURLWithPath: daftPath!)
        harderPlayer = AVAudioPlayer(contentsOfURL: daftURL, error: nil)
        harderPlayer!.prepareToPlay()
        
        let betterPath = NSBundle.mainBundle().pathForResource("better", ofType: "wav")
        let betterURL = NSURL(fileURLWithPath: betterPath!)
        betterPlayer = AVAudioPlayer(contentsOfURL: betterURL, error: nil)
        betterPlayer!.prepareToPlay()
        
        let fasterPath = NSBundle.mainBundle().pathForResource("faster", ofType: "wav")
        let fasterURL = NSURL(fileURLWithPath: fasterPath!)
        fasterPlayer = AVAudioPlayer(contentsOfURL: fasterURL, error: nil)
        fasterPlayer!.prepareToPlay()
        
        let strongerPath = NSBundle.mainBundle().pathForResource("stronger", ofType: "wav")
        let strongerURL = NSURL(fileURLWithPath: strongerPath!)
        strongerPlayer = AVAudioPlayer(contentsOfURL: strongerURL, error: nil)
        strongerPlayer!.prepareToPlay()
        
        //Adapt position of phoneContainerView
        if self.view.frame.size.height > 500 {
            //containerView.frame = CGRect(x: containerView.frame.origin.x, y: 60, width: containerView.frame.size.width, height: containerView.frame.size.height)
            
        }
        else{
            /*countryButton.frame = CGRect(x: countryButton.frame.origin.x, y: countryButton.frame.origin.y - 20, width: self.view.frame.size.width, height: 40)
            phoneContainerView.frame = CGRect(x: phoneContainerView.frame.origin.x, y: phoneContainerView.frame.origin.y - 30, width: self.view.frame.size.width, height: 40)
            phoneNumberIndicator!.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width/4, height: 40)
            phoneNumberTextField!.frame = CGRect(x: self.view.frame.size.width/4, y: 0, width: self.view.frame.size.width/4 * 3, height: 40)*/
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func chooseCountry(sender: AnyObject) {
    }
    
    // MARK: Error Handler
    
    func confirmationCodeErrorHandler() {
        if Utils().iOS8 {
            var alert = UIAlertController(title: LocalizedString("Error"),
                message: LocalizedString("Error while getting the confirmation code. Please try again later."), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: LocalizedString("Ok"), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            UIAlertView(title: LocalizedString("Error"), message: LocalizedString("Error while getting the confirmation code. Please try again later."), delegate: nil, cancelButtonTitle: LocalizedString("Ok")).show()
        }
    }
    
    func wrongPhoneNumberErrorHandler() {
        if Utils().iOS8 {
            var alert = UIAlertController(title: LocalizedString("Error"), message: LocalizedString("Sorry but your phone number is not valid") , preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: LocalizedString("Ok"), style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            UIAlertView(title: LocalizedString("Error"), message: LocalizedString("Sorry but your phone number is not valid"), delegate: nil, cancelButtonTitle: LocalizedString("Ok")).show()
        }
    }
    
    
    //Verify Phone Number and send verification code
    func sendConfCode(sender : UIButton){
        
        if phoneNumberValid{
            //Loader
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            //get phone number and verify it
            let phoneNumber = phoneNumberTextField!.text
            
            if phoneNumber != nil {
                let phoneUtil:NBPhoneNumberUtil = NBPhoneNumberUtil()
                var errorPointer:NSError?
                var number:NBPhoneNumber = phoneUtil.parse(phoneNumber, defaultRegion:regionLabel, error:&errorPointer)
                
                if errorPointer == nil{
                    if phoneUtil.isValidNumber(number){
                        
                        var errorPhone:NSError?
                        let phoneNumber:String = phoneUtil.format(number, numberFormat: NBEPhoneNumberFormatE164, error: &errorPhone)
                        
                        if errorPhone == nil {
                            self.finalFormatedNumber = phoneNumber
                            
                            self.verificationCode = "3333"
                            
                            //Valid Number ask server to send code
                            PFCloud.callFunctionInBackground("confirmPhoneNumber", withParameters: ["phoneNumber":phoneNumber], block: { (object, error) -> Void in
                                MBProgressHUD.hideHUDForView(self.view, animated: true)
                                if error != nil {
                                    self.confirmationCodeErrorHandler()
                                }
                                else{
                                    var result:AnyObject = object![0]
                                    println("All : \(result)")
                                    var code:Int = result["randomNumber"] as! Int
                                    
                                    if let username: String? = result["username"] as? String{
                                        self.username = username
                                    }

                                    self.verificationCode = "\(code)"
                                    
                                    if self.verificationCode != nil {
                                        self.performSegueWithIdentifier("verificationCode", sender: self)
                                    }
                                    else{
                                        self.confirmationCodeErrorHandler()
                                    }
                                    
                                }
                            })
                        }
                        else{
                            println("Problem formating the nb")
                        }
                    }
                    else{
                        //Not valid number
                        self.wrongPhoneNumberErrorHandler()
                    }
                }
                else{
                    println("Problem parsing the phone number")
                }
            }
        }
    }
    
    
    /*
    * TextField Delegate
    */
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var shouldReplace = true
        
        
        
        
        var finalText:NSString = textField.text as NSString
        finalText = finalText.stringByReplacingCharactersInRange(range, withString: string)
        
        
        if finalText.length > 14{
            return false
        }
        
        if finalText.length > (textField.text as NSString).length{
            if !isAllowed(string){
                return false
            }
            
            textField.text = phoneFormatter!.inputDigit(string)
        }
        else{
            textField.text = phoneFormatter!.removeLastDigit()
        }
        
        
        
        
        if finalText.length > 2{
            if isCorrectPhoneNumber(finalText as String){
                phoneNumberValid = true
                validatePhoneView!.backgroundColor = Utils().secondColor
            }
            else{
                phoneNumberValid = false
                validatePhoneView!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
            }
        }
        else{
            phoneNumberValid = false
            validatePhoneView!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        }
        
        
        
        return false
    }
    
    
    //Keyboard Notifs
    func keyboardWillShow(notification : NSNotification){
        
        let info:NSDictionary = notification.userInfo!
        keyboardSize = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue().size
        
        if self.view.frame.size.height > 500 {
            validatePhoneView!.frame = CGRect(x: 0, y: self.view.frame.size.height - keyboardSize!.height - 55, width: self.view.frame.size.width, height: 55)
            phoneNumberView!.frame = CGRect(x: phoneNumberView!.frame.origin.x, y: validatePhoneView!.frame.origin.y - phoneNumberView!.frame.height - 20, width: phoneNumberView!.frame.width, height: phoneNumberView!.frame.height)
        }
        else{
            validatePhoneView!.frame = CGRect(x: 0, y: self.view.frame.size.height - keyboardSize!.height - 55, width: self.view.frame.size.width, height: 55)
            phoneNumberView!.frame = CGRect(x: phoneNumberView!.frame.origin.x, y: validatePhoneView!.frame.origin.y - phoneNumberView!.frame.height - 20, width: phoneNumberView!.frame.width, height: phoneNumberView!.frame.height)
            
        }

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "verificationCode"{
            
            var nextController:VerificationCodePhoneViewController = segue.destinationViewController as! VerificationCodePhoneViewController
            nextController.verificationCode = self.verificationCode
            nextController.phoneNumber = self.finalFormatedNumber
            nextController.keyboardSize = self.keyboardSize
            nextController.regionCode = self.regionLabel
            
            if username != nil{
                nextController.username = username
            }
        }
        else if segue.identifier == "listCountry"{
            
            var navController:UINavigationController = segue.destinationViewController as! UINavigationController
            var listCountriesViewController:CountriesTableViewController = navController.viewControllers[0] as! CountriesTableViewController
            listCountriesViewController.countriesInfos = self.countriesInfos
            listCountriesViewController.delegate = self
            
        }
        
    }
    
    
    func isCorrectPhoneNumber(phone : String) -> Bool{

        if regionLabel != nil{
            let phoneUtil:NBPhoneNumberUtil = NBPhoneNumberUtil()
            var errorPointer:NSError?
            var number:NBPhoneNumber? = phoneUtil.parse(phone, defaultRegion:regionLabel!, error:&errorPointer)
            
            println("Phone : \(phone), region label : \(regionLabel), region code :")
            println("Number : \(number)")
            
            if errorPointer == nil{
                if phoneUtil.isValidNumber(number){
                    return true
                }
                else{
                    return false
                }
            }
        }
        
        
        
        return false
        
    }
    
    
    /*
    * Countries Delegate
    */
    
    func choseCountry(countryChoiceInfos : [String : String]) {
        var countryName = countryChoiceInfos["countryName"]
        println("Country name : \(countryName)")
        
        self.regionLabel = countryChoiceInfos["countryLetters"]
        countryButton.setTitle(countryChoiceInfos["countryName"], forState: UIControlState.Normal)
        let countryNumbers:String = countryChoiceInfos["countryCode"]!
        phoneNumberIndicator!.text = "+\(countryNumbers)"
        indicatorLabel!.text = "+\(countryNumbers)"
        countryLabel!.text = countryChoiceInfos["countryName"]! as String
        
        phoneNumberTextField!.text = ""
        phoneFormatter!.clear()
        phoneFormatter = NBAsYouTypeFormatter(regionCode: self.regionLabel!)
        
        phoneNumberValid = false
        validatePhoneView!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        
    }
    
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func chooseNumberAction(gesture : UITapGestureRecognizer){
        
        self.performSegueWithIdentifier("listCountry", sender: self)
        
    }
    
    
    func  daftAnim(gesture : UITapGestureRecognizer){
        
        
        
        
        switch incrementPlayer%4{
        case 0:
            harderPlayer!.play()
        case 1:
            betterPlayer!.play()
        case 2:
            fasterPlayer!.play()
        case 3:
            strongerPlayer!.play()
        default:
            harderPlayer!.play()
        }
        
        incrementPlayer++
        
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.daftImageView.transform = CGAffineTransformMakeScale(2.0, 2.0)
        }) { (finished) -> Void in
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.daftImageView.transform = CGAffineTransformIdentity
                }) { (finished) -> Void in
                    
            }
        }
        
    }
    
    
    func isAllowed(string : String) -> Bool{
        
        let allowedCharacters : Array<String> = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        
        if contains(allowedCharacters, string){
            return true
        }
        else{
            return false
        }
    }
    
    
}