//
//  SettingsViewController.swift
//  Pleek
//
//  Created by Adrien Dulong on 17/01/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation
import MessageUI
import Social

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var mainSwitch: UISwitch!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var emojiImageView: UIImageView!
    
    func updateSwitch(){
        
        var installation:PFInstallation = PFInstallation.currentInstallation()
        let notificationsEnabled:Bool? = installation["notificationsEnabled"] as? Bool
        
        if notificationsEnabled != nil{
            if notificationsEnabled!{
                mainSwitch.on = true
                emojiImageView.image = UIImage(named: "notification_enable")
            }
            else{
                mainSwitch.on = false
                emojiImageView.image = UIImage(named: "notification_disable")
            }
        }
        else{
            mainSwitch.on = true
            emojiImageView.image = UIImage(named: "notification_enable")
        }
        
    }
    
    
    @IBAction func changePropertie(sender: AnyObject) {
        
        if mainSwitch.on{
            println("Enable notifications")
            var installation:PFInstallation = PFInstallation.currentInstallation()
            installation["notificationsEnabled"] = true
            installation.saveEventually()
            emojiImageView.image = UIImage(named: "notification_enable")
        }
        else{
            println("Disable Notifications")
            var installation:PFInstallation = PFInstallation.currentInstallation()
            installation["notificationsEnabled"] = false
            installation.saveEventually()
            emojiImageView.image = UIImage(named: "notification_disable")
            
        }
        
    }
}


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    var changeUsernameChosen:Bool = true
    var documentInteractionController:UIDocumentInteractionController?
    
    override func viewDidLoad() {
        
        let backStatusBar:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        backStatusBar.backgroundColor = Utils().statusBarColor
        self.view.addSubview(backStatusBar)
        
        var bundleVersion:String? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        appVersionLabel.text = "v\(bundleVersion!)"
        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("logOut"))
        tapGesture.numberOfTapsRequired = 3
        settingsLabel.userInteractionEnabled = true
        settingsLabel.addGestureRecognizer(tapGesture)
        
        settingsLabel.text = NSLocalizedString("Settings", comment : "Settings")
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    @IBAction func leaveSettings(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    
    // MARK: Table View DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }
        else{
            return 32
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 0{
            
            var headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 32))
            headerView.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
            
            var labelHeader = UILabel(frame: CGRect(x: 15, y: 0, width: headerView.frame.width - 30, height: headerView.frame.height))
            labelHeader.font = UIFont(name: Utils().customFontSemiBold, size: 16)
            labelHeader.textColor = UIColor.whiteColor()
            
            switch section{
            case 1:
                labelHeader.text = NSLocalizedString("NOTIFICATIONS", comment : "NOTIFICATIONS")
            case 2:
                labelHeader.text = NSLocalizedString("SUPPORT", comment : "SUPPORT")
            case 3:
                labelHeader.text = NSLocalizedString("OTHER", comment : "OTHER")
            default:
                labelHeader.text = NSLocalizedString("OTHER", comment : "OTHER")
            }
            
            headerView.addSubview(labelHeader)
            
            return headerView
            
        }
        else{
            return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 4
        case 1:
            return 1
        case 2:
            return 2
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell:SettingsTableViewCell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as! SettingsTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.secondLabel.hidden = true
        
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                cell.mainLabel.transform = CGAffineTransformMakeTranslation(0, -10)
                cell.secondLabel.transform = CGAffineTransformMakeTranslation(0, -5)
                cell.mainLabel.text = NSLocalizedString("Change Username", comment : "Change Username")
                cell.mainSwitch.hidden = true
                cell.secondLabel.hidden = false
                cell.emojiImageView.image = UIImage(named: "username_emoji")
                cell.secondLabel.text = "@\(PFUser.currentUser()!.username!)"
            case 1:
                cell.mainLabel.transform = CGAffineTransformMakeTranslation(0, -10)
                cell.secondLabel.transform = CGAffineTransformMakeTranslation(0, -5)
                cell.mainLabel.text = NSLocalizedString("Change my name", comment : "Change my name")
                cell.mainSwitch.hidden = true
                cell.secondLabel.hidden = false
                cell.emojiImageView.image = UIImage(named: "name_emoji")
                
                if PFUser.currentUser()!["name"] != nil{
                    cell.secondLabel.text = PFUser.currentUser()!["name"] as? String
                }
                else{
                    cell.secondLabel.text = "undefined"
                }
                
                
            case 2:
                cell.mainLabel.transform = CGAffineTransformIdentity
                cell.mainLabel.text = "Popular accounts"
                cell.emojiImageView.image = UIImage(named: "recommand_emoji")
                cell.mainSwitch.hidden = true
                
            case 3:
                cell.mainLabel.text = "Create my Pleek ID"
                cell.mainLabel.transform = CGAffineTransformIdentity
                cell.emojiImageView.image = UIImage(named: "share_emoji")
                cell.mainSwitch.hidden = true
                
            default:
                cell.mainLabel.text = NSLocalizedString("Change Username", comment : "Change Username")
                cell.mainSwitch.hidden = true
            }
            
        case 1:
            
            switch indexPath.row{
            case 0:
                cell.mainLabel.text = NSLocalizedString("Notifications", comment : "Notifications")
                cell.mainSwitch.hidden = false
                cell.mainLabel.transform = CGAffineTransformIdentity
                cell.mainSwitch.onTintColor = Utils().secondColor
                cell.updateSwitch()

            default:
                cell.mainLabel.text = NSLocalizedString("Notifications", comment : "Notifications")
                cell.mainSwitch.hidden = false
                cell.mainLabel.transform = CGAffineTransformIdentity
                cell.emojiImageView.image = UIImage(named: "notification_emoji")
                cell.updateSwitch()
            }
            
            
        case 2:
            switch indexPath.row{
            case 0:
                cell.mainLabel.text = NSLocalizedString("Email Us", comment : "Email Us")
                cell.mainSwitch.hidden = true
                cell.mainLabel.transform = CGAffineTransformIdentity
                cell.emojiImageView.image = UIImage(named: "mail_emoji")
            case 1:
                cell.mainLabel.text = NSLocalizedString("Tweet Us", comment : "Tweet Us")
                cell.mainLabel.transform = CGAffineTransformIdentity
                cell.emojiImageView.image = UIImage(named: "tweet_emoji")
                cell.mainSwitch.hidden = true
            default:
                cell.mainLabel.text = NSLocalizedString("Tweet Us", comment : "Tweet Us")
                cell.mainLabel.transform = CGAffineTransformIdentity
                cell.mainSwitch.hidden = true
            }
        case 3:
            switch indexPath.row{
            case 0:
                //cell.mainLabel.text = NSLocalizedString("Share the app", comment : "Share the app")
                cell.mainLabel.text = "Create my Pleek ID"
                cell.mainLabel.transform = CGAffineTransformIdentity
                cell.emojiImageView.image = UIImage(named: "share_emoji")
                cell.mainSwitch.hidden = true
            default:
                cell.mainLabel.text = "Create my Pleek ID"
                //cell.mainLabel.text = NSLocalizedString("Share the app", comment : "Share the app")
                cell.mainLabel.transform = CGAffineTransformIdentity
                cell.mainSwitch.hidden = true
            }
        default:
            cell.mainLabel.text = NSLocalizedString("Share the app", comment : "Share the app")
            cell.mainLabel.transform = CGAffineTransformIdentity
            cell.mainSwitch.hidden = true
            
        }
        
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                changeUsernameChosen = true
                self.performSegueWithIdentifier("changeUsername", sender: self)
                
            case 1:
                changeUsernameChosen = false
                self.performSegueWithIdentifier("changeUsername", sender: self)
                
            case 2:
                self.performSegueWithIdentifier("showRecommendedAccounts", sender: self)
                
            case 3:
                shareTheApp()
                
            default:
                self.performSegueWithIdentifier("changeUsername", sender: self)
            }
        case 2:
            switch indexPath.row{
            case 0:
                sendEmail()
            case 1:
                tweetUs()
            default:
                println("coucou")
            }
        case 3:
            switch indexPath.row{
            case 0:
                shareTheApp()
            default:
                println("coucou")
            }
        default:
            println("coucou")
            
        }
        
    }
    
    
    // MARK: Actions Functions
    
    func sendEmail(){
        let emailTitle = "Hey you!"
        let messageBody = "I wanted to let you know that ..."
        let toRecipents = ["yo@pleekapp.com"]
        var mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        self.presentViewController(mc, animated: true, completion: nil)
    }
    
    func tweetUs(){
        var okTwitter :Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
        
        if okTwitter{
            var composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            composer.setInitialText("Hey @Pleekapp")
            
            composer.completionHandler = {
                (result:SLComposeViewControllerResult) in
                println("Result : \(result)")
            }
            self.presentViewController(composer, animated: true, completion: nil)
            
        }
        else{
            
        }
    }
    
    func shareTheApp(){
        
        
        let someText:String = "Add me on #Pleek"
        let google:NSURL = NSURL(string: Utils().shareAppUrl)!
        var image:UIImage = Utils().buildPleekId()
        
        // let's add a String and an NSURL
        let activityViewController = UIActivityViewController(
            activityItems: [someText, google, image],
            applicationActivities: nil)
        self.navigationController!.presentViewController(activityViewController,
            animated: true, 
            completion: nil)
        
    }
    
    // MARK: Mail Delegate
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        switch result.value {
        case MFMailComposeResultCancelled.value:
            NSLog("Mail cancelled")
        case MFMailComposeResultSaved.value:
            NSLog("Mail saved")
        case MFMailComposeResultSent.value:
            NSLog("Mail sent")
        case MFMailComposeResultFailed.value:
            NSLog("Mail sent failure: %@", [error.localizedDescription])
        default:
            break
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    // MARK: Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    // MARK: HIDDEN Log Out
    
    func logOut(){
        PFUser.logOut()
    }
    
    
    //MARK : PRepare Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "changeUsername"{
            
            var targetController:EditUsernameViewController = segue.destinationViewController as! EditUsernameViewController
            targetController.changeUsernameChosen = self.changeUsernameChosen
        }
        
    }
    

    
    
    
    
}