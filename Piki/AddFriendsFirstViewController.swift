//
//  AddFriendsFirstViewController.swift
//  Pleek
//
//  Created by Adrien Dulong on 04/02/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation
import MessageUI
import CoreTelephony


class ContactCell: UITableViewCell {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    var contact:APContact?
    var userInfos:[String : AnyObject]?
    
    func loadCellwithContact(contact: APContact, isSelected : Bool){
        
        self.checkImageView.image = UIImage(named: "select_check_empty")
        self.contact = contact
        self.userInfos = nil
        
        username.text = self.contact!.compositeName
        fullName.hidden = true
        
        if isSelected{
            self.checkImageView.image = UIImage(named: "select_check_full")
        }
        else{
            self.checkImageView.image = UIImage(named: "select_check_empty")
        }
    }
    
    func loadCellWithUserInfos(userInfos: [String : AnyObject], isSelected: Bool){
        
        self.checkImageView.image = UIImage(named: "select_check_empty")
        self.userInfos = userInfos
        self.contact = nil

        var contact:APContact? = userInfos["contact"] as? APContact
        if contact != nil{
            fullName.text = contact!.compositeName
        }
        
        println("Userinfos : \(userInfos)")
        
        var userInfosDic:[String : String] = userInfos["userInfos"] as! [String : String]
        var usernameString = userInfosDic["username"]
        username.text = "@\(usernameString!)"
        
        fullName.hidden = false
        
        
        if isSelected{
            self.checkImageView.image = UIImage(named: "select_check_full")
        }
        else{
            self.checkImageView.image = UIImage(named: "select_check_empty")
        }
    }

    
    func select(){
        self.checkImageView.image = UIImage(named: "select_check_full")
        UIView.animateWithDuration(0.1,
            delay: 0,
            options:nil,
            animations: { () -> Void in
                self.checkImageView.transform = CGAffineTransformMakeScale(1.6, 1.6)
            }) { (finished) -> Void in
                
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.checkImageView.transform = CGAffineTransformIdentity
                })
                
        }
    }
    
    func deselect(){
        self.checkImageView.image = UIImage(named: "select_check_empty")
    }
    
}


class AddFriendsFirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var sendIcon: UIImageView!
    @IBOutlet weak var inviteAllActionLabel: UILabel!
    @IBOutlet weak var mainActionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let addressBook = APAddressBook()
    var contactsPhone:Array<APContact> = []
    var lookingForFriendsOnPeekee:Bool = false
    var regionLabel:String?
    var pikiUsersFromPhoneContacts:Array<[String : String]> = Array<[String : String]>()
    var contactsWithUserInfos:Array<[String : AnyObject]> = Array<[String : AnyObject]>()
    
    var usersSelected:Array<String> = Array<String>()
    var contactsSelected:Array<APContact> = Array<APContact>()
    var secondButtonLabel:String!
    var mainOriginLabel:String!
    var mandatoryStep:Bool = false
    
    var secondButton:UIButton!
    var invitingUsers:Bool = false
    var invitingContacts:Bool = false
    var limitFriendsInvit:Int = 5
    
    
    //POP UP
    var rootPopUpView:UIView?
    var rootOverlay:UIView?
    
    override func viewDidLoad() {
        
        Mixpanel.sharedInstance().track("First Add Friends View")
        
        var defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("mandatoryFriends") != nil{
            self.mandatoryStep = defaults.objectForKey("mandatoryFriends") as! Bool
        }
        
        if defaults.objectForKey("numberToAdd") != nil{
            self.limitFriendsInvit = defaults.objectForKey("numberToAdd") as! Int
        }
        
        titleLabel.text = NSLocalizedString("Add your friends! 👫", comment :"Add your friends! 👫")
        let invitLabel = String(format:NSLocalizedString("Choose at least your %d best friends. We'll keep you posted when they join the app!", comment :"Choose at least your %d best friends. We'll keep you posted when they join the app!"), self.limitFriendsInvit)
        subtitleLabel.text = invitLabel
        
        
        
        
        // Get region label
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        if carrier != nil {
            regionLabel = carrier.isoCountryCode
        }
        else{
            regionLabel = "us"
        }
        
        if regionLabel == nil {
            regionLabel = "us"
        }
        
        if mandatoryStep{
            secondButtonLabel = NSLocalizedString("ALL", comment :"ALL")
            mainOriginLabel = NSLocalizedString("INVITE ALL", comment :"INVITE ALL")
        }
        else{
            secondButtonLabel = NSLocalizedString("SKIP", comment :"SKIP")
            mainOriginLabel = NSLocalizedString("SKIP", comment :"SKIP")
        }
        
        self.inviteAllActionLabel.text = self.mainOriginLabel
        
        secondButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.height - 55, width: self.view.frame.width/3, height: 55))
        secondButton!.backgroundColor = UIColor(red: 233/255, green: 54/255, blue: 115/255, alpha: 1.0)
        secondButton.setTitle(secondButtonLabel, forState: UIControlState.Normal)
        secondButton.titleLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 20)
        secondButton.addTarget(self, action: Selector("secondInvit"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(secondButton)
        secondButton.transform = CGAffineTransformMakeTranslation(-secondButton.frame.width, 0)
        
        
        var gestureMainAction:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("mainInvit"))
        self.mainActionView.addGestureRecognizer(gestureMainAction)
        
        //Get contacts
        //getContacts()
        
        self.mainActionView.hidden = true
        createPopUp()
        
    }

    // MARK: Table View Datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var viewHeader:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 32))
        viewHeader.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        
        var labelHeader:UILabel = UILabel(frame: CGRect(x: 10, y: 0, width: viewHeader.frame.size.width, height: 32))
        labelHeader.font = UIFont(name: Utils().customFontSemiBold, size: 16.0)
        labelHeader.textColor = UIColor.whiteColor()
        viewHeader.addSubview(labelHeader)
        
        if section == 0{
            
            if self.lookingForFriendsOnPeekee{
                viewHeader.backgroundColor = Utils().secondColor
                labelHeader.textAlignment = NSTextAlignment.Center
                viewHeader.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
                
                labelHeader.text = NSLocalizedString("LOOKING FOR FRIENDS", comment : "LOOKING FOR FRIENDS")
                
                var loadIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
                loadIndicator.tintColor = UIColor.whiteColor()
                loadIndicator.center = CGPoint(x: viewHeader.frame.width/2, y: viewHeader.frame.height/2 + viewHeader.frame.height/4 - 3)
                loadIndicator.hidesWhenStopped = true
                loadIndicator.startAnimating()
                viewHeader.addSubview(loadIndicator)
            }
            else{
                viewHeader.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
                labelHeader.textAlignment = NSTextAlignment.Left
                labelHeader.text = NSLocalizedString("ON THE APP", comment : "ON THE APP")
            }
            
        }
        else{
            labelHeader.text = NSLocalizedString("ON YOUR PHONE CONTACTS", comment :"ON YOUR PHONE CONTACTS")
        }
        
        return viewHeader
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            if self.lookingForFriendsOnPeekee{
                return 64
            }
            else{
                return 32
            }
        }
        else{
            return 32
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return contactsWithUserInfos.count
        }
        else{
            return contactsPhone.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ContactCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ContactCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if indexPath.section == 0{
            var contactInfos = contactsWithUserInfos[indexPath.row]
            var userInfos:[String : String] = contactInfos["userInfos"] as! [String : String]
            
            cell.loadCellWithUserInfos(contactsWithUserInfos[indexPath.row], isSelected : isUserSelected(userInfos))
        }
        else if indexPath.section == 1{
            cell.loadCellwithContact(contactsPhone[indexPath.row], isSelected : isContactSelected(contactsPhone[indexPath.row]))
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0{
            
            var contactInfos = contactsWithUserInfos[indexPath.row]
            var userInfos:[String : String] = contactInfos["userInfos"] as! [String : String]
            var objectIdUser:String = userInfos["userObjectId"]!
            
            if !contains(usersSelected, objectIdUser){
                usersSelected.append(objectIdUser)
                var cell:ContactCell = self.tableView.cellForRowAtIndexPath(indexPath) as! ContactCell
                cell.select()
                self.tableView.reloadData()
                
            }
            else{
                
                
                var index:Int?
                var position : Int = 0
                for userSelected in usersSelected{
                    if userSelected == objectIdUser{
                        index = position
                    }
                    position++
                }
                
                if index != nil{
                    usersSelected.removeAtIndex(index!)
                    var cell:ContactCell = self.tableView.cellForRowAtIndexPath(indexPath) as! ContactCell
                    cell.deselect()
                    self.tableView.reloadData()
                }
                
                
            }
            
        }
        else{
            var contact:APContact = contactsPhone[indexPath.row]
            
            if !contains(contactsSelected, contact){
                contactsSelected.append(contact)
                var cell:ContactCell = self.tableView.cellForRowAtIndexPath(indexPath) as! ContactCell
                cell.select()
                self.tableView.reloadData()
            }
            else{
                
                
                var index:Int?
                var position : Int = 0
                for contactSelected in contactsSelected{
                    if contactSelected == contact{
                        index = position
                    }
                    position++
                }
                
                if index != nil{
                    contactsSelected.removeAtIndex(index!)
                    var cell:ContactCell = self.tableView.cellForRowAtIndexPath(indexPath) as! ContactCell
                    cell.deselect()
                    self.tableView.reloadData()
                }
                
            }
        }
        
        if (contactsSelected.count > 0) || (usersSelected.count > 0){
            
            //self.inviteAllActionLabel.hidden = true
            self.inviteAllActionLabel.text = ""
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.secondButton.transform = CGAffineTransformIdentity
                    
                    self.inviteAllActionLabel.frame = CGRect(x: self.secondButton.frame.width, y: 0, width: self.view.frame.width - self.view.frame.width/3, height: 55)
            }, completion: { (finished) -> Void in
                let nbSelected:Int = (self.usersSelected.count + self.contactsSelected.count) as Int
                let invitLabel = String(format: NSLocalizedString("INVITE %d/%d", comment : "INVITE %d/%d"), nbSelected, self.limitFriendsInvit)
                self.inviteAllActionLabel.text = invitLabel
            })
            
        }
        else{
            self.inviteAllActionLabel.text = ""
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.secondButton.transform = CGAffineTransformMakeTranslation(-self.secondButton.frame.width, 0)
                    self.mainActionView.frame = CGRect(x: 0, y: self.view.frame.height - 55, width: self.view.frame.width, height: 55)
                    self.inviteAllActionLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 55)
                }, completion: { (finished) -> Void in
                    self.inviteAllActionLabel.text = self.mainOriginLabel
            })
            
        }
    }
    
    // MARK: User Selection
    
    func isUserSelected(userInfos : [String : String]) -> Bool{
        var objectIdUser:String = userInfos["userObjectId"]!
        
        if contains(usersSelected, objectIdUser){
            return true
        }
        
        return false
    }
    
    // MARK : Contact Selection
    
    func isContactSelected(contact : APContact) -> Bool{
        
        if contains(contactsSelected, contact){
            return true
        }
        
        return false
        
    }
    
    
    
    // MARK: Status Bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    // MARK: Contact Access
    
    func getContacts(){
        //Contacts
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.addressBook.fieldsMask = APContactField.All
        self.addressBook.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true),
            NSSortDescriptor(key: "lastName", ascending: true)]
        self.addressBook.filterBlock = {(contact: APContact!) -> Bool in
            return contact.phones.count > 0
        }
        self.addressBook.loadContacts(
            { (contacts: [AnyObject]!, error: NSError!) in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                if (contacts != nil) {

                    self.contactsPhone = contacts as! Array<APContact>
                    self.lookingForFriendsOnPeekee = true
                    self.tableView.reloadData()
                    
                    self.mainActionView.hidden = false
                    
                    self.checkContactsOnPiki()
                }
                else if (error != nil) {
                    self.goLeave()
                }
        })
    }
    
    
    
    // MARK : Friends on Pleek
    
    func checkContactsOnPiki(){
        
        var phoneNumbers:Array<String> = []
        
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        
        
        
        let phoneUtil:NBPhoneNumberUtil = NBPhoneNumberUtil()
        
        
        
        for contact in self.contactsPhone{
            
            for tel in contact.phones{
                
                if (tel as? String) != nil {
                    
                    if count(tel as! String) > 6{
                        var errorPointer:NSError?
                        var number:NBPhoneNumber? = phoneUtil.parse(tel as! String, defaultRegion:regionLabel!, error:&errorPointer)
                        if errorPointer == nil {
                            if phoneUtil.isValidNumber(number!){
                                
                                var errorPhone:NSError?
                                let phoneNumber:String? = phoneUtil.format(number, numberFormat: NBEPhoneNumberFormatE164, error: &errorPhone)
                                
                                if errorPhone == nil {
                                    phoneNumbers.append(phoneNumber!)
                                }
                                
                                
                            }
                        }
                    }
                }
                
                
                
                
                
            }
            
        }
        
        PFCloud.callFunctionInBackground("checkContactOnPiki", withParameters: ["phoneNumbers" : phoneNumbers]) { (pikiUsers, error) -> Void in
            if error != nil {
                self.lookingForFriendsOnPeekee = false
                self.tableView.reloadData()
            }
            else{
                println("Piki users : \(pikiUsers)")
                self.pikiUsersFromPhoneContacts = pikiUsers as! Array<[String : String]>
                self.getAllUsersFromContacts()
            }
        }
        
    }
    
    
    func getAllUsersFromContacts(){
        
        dispatch_async(dispatch_get_global_queue(0, 0), {
            var tempContactsWithUserInfos:Array<[String : AnyObject]> = Array<[String : AnyObject]>()
            
            
            var friendsUserId:Array<String>? = Utils().getAppDelegate().friendsIdList
            var usersFromContacts:Array<[String : String]> = Array<[String : String]>()
            var arrayPhoneUsers:Array<String> = Array<String>()
            
            for userInfos in self.pikiUsersFromPhoneContacts{
                if !contains(friendsUserId!, userInfos["userObjectId"]!){
                    var idUser = userInfos["userObjectId"]!
                    
                    usersFromContacts.append(userInfos)
                    
                    if userInfos["phoneNumber"] != nil{
                        arrayPhoneUsers.append(userInfos["phoneNumber"]!)
                    }
                }
            }
            
            
            for contact in self.contactsPhone{
                
                for phone in contact.phones{
                    
                    
                    let formatedPhone:String? = self.getFormattedPhoneNumber(phone as! String)
                    
                    if formatedPhone != nil{
                        if contains(arrayPhoneUsers, formatedPhone!){
                            for userInfos in usersFromContacts{
                                
                                if userInfos["phoneNumber"] == formatedPhone{
                                    tempContactsWithUserInfos.append(["userInfos" : userInfos, "contact" : contact])
                                }
                                
                            }
                        }
                    }
                    
                }
                
            }
            
            
            
            
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.contactsWithUserInfos = tempContactsWithUserInfos
                self.lookingForFriendsOnPeekee = false
                self.tableView.reloadData()
            })
        })
        
    }
    
    func getFormattedPhoneNumber(numberString : String) -> String? {
        var finalPhoneNumber:String?
        
        
        let phoneUtil:NBPhoneNumberUtil = NBPhoneNumberUtil()
        var errorPointer:NSError?
        
        if count(numberString) > 4{
            var number:NBPhoneNumber? = phoneUtil.parse(numberString, defaultRegion:regionLabel!, error:&errorPointer)
            if errorPointer == nil {
                if phoneUtil.isValidNumber(number){
                    let phoneNumber:String = phoneUtil.format(number, numberFormat: NBEPhoneNumberFormatE164, error: nil)
                    return phoneNumber
                }
            }
        }
        
        return finalPhoneNumber
    }
    
    
    // MARK: Main Function Invit
    
    func mainInvit(){
        
        
        
        //Users seelcted ?
        if(usersSelected.count > 0) || (contactsSelected.count > 0){
            
            
            var totalUserSeelcted:Int = usersSelected.count + contactsSelected.count
            
            if totalUserSeelcted > (limitFriendsInvit - 1){
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                if usersSelected.count > 0{
                    // Add as friends
                    invitingUsers = true
                    
                    var tasks = NSMutableArray()
                    
                    for user in usersSelected{
                        
                        tasks.addObject(Utils().addFriend(user))
                        
                    }
                    BFTask(forCompletionOfAllTasks:tasks as Array<AnyObject>).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                        
                        println("finished adding friends")
                        self.invitingUsers = false
                        
                        Mixpanel.sharedInstance().track("Add Friend", properties : ["screen" : "add_first_friend"])
                        
                        if !self.invitingUsers && !self.invitingContacts{
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                            self.goLeave()
                        }
                        
                        return nil
                    })
                }
                
                if contactsSelected.count > 0{
                    invitingContacts = true
                    
                    self.sendSMSToContacts(contactsSelected)
                }
                
                
            }
            else{
                //Still
                var stillToGo:Int = limitFriendsInvit - totalUserSeelcted
                let nbRecipientsFormat = String(format: NSLocalizedString("Still %d to go! You need them to enjoy Pleek!", comment : "Still %d to go! You need them to enjoy Pleek!"), stillToGo)
                let alert = UIAlertView(title: NSLocalizedString("Friends", comment : "Friends"), message: nbRecipientsFormat,
                    delegate: nil, cancelButtonTitle: "Ok")
                alert.show()
                
            }
            
        }
        else{
            if mandatoryStep{
                //Invite All !
                //Ask Before
                if Utils().iOS8{
                    var alert = UIAlertController(title: "Confirmation", message: NSLocalizedString("Are you sure you want to invite all your contacts?", comment : "Are you sure you want to invite all your contacts?"), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment : "No"), style: UIAlertActionStyle.Cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment : "Yes"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                        self.sendSmsFromSeverTo(self.getArrayOfAllNumbers())
                        self.goLeave()
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else{
                    
                    var alertView = UIAlertView(title: "Confirmation",
                        message: NSLocalizedString("Are you sure you want to invite all your contacts?",
                            comment : "Are you sure you want to invite all your contacts?"),
                        delegate: self, cancelButtonTitle: NSLocalizedString("No", comment : "No"),
                        otherButtonTitles: NSLocalizedString("Yes", comment : "Yes"))
                    alertView.delegate = self
                    alertView.show()
                    
                    
                    
                }
                
                
                
            }
            else{
                
                Mixpanel.sharedInstance().track("Skip Invit", properties: ["is_big_one" : true])
                
                
                // Leave
                goLeave()
            }
        }
        
    }
    
    func secondInvit(){
        
        if mandatoryStep{
            //Invite All !
            if Utils().iOS8{
                var alert = UIAlertController(title: NSLocalizedString("Confirmation", comment : "Confirmation"), message: NSLocalizedString("Are you sure you want to invite all your contacts?", comment : "Are you sure you want to invite all your contacts?"), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment : "No"), style: UIAlertActionStyle.Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment : "Yes"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                    self.sendSmsFromSeverTo(self.getArrayOfAllNumbers())
                    self.goLeave()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else{
                var alertView = UIAlertView(title: "Confirmation",
                    message: NSLocalizedString("Are you sure you want to invite all your contacts?",
                        comment : "Are you sure you want to invite all your contacts?"),
                    delegate: self, cancelButtonTitle: NSLocalizedString("No", comment : "No"),
                    otherButtonTitles: NSLocalizedString("Yes", comment : "Yes"))
                alertView.delegate = self
                alertView.show()
            }
            
        }
        else{
            // Leave
            Mixpanel.sharedInstance().track("Skip Invit", properties: ["is_big_one" : false])
            goLeave()
        }
        
    }
    
    
    // MARK: SMS
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch (result.value) {
        case MessageComposeResultCancelled.value:
            //Send from server
            self.sendSmsFromSeverTo(getArrayOfNumbersForContacts(contactsSelected))
            
        case MessageComposeResultFailed.value:
            //Send from Server
            self.sendSmsFromSeverTo(getArrayOfNumbersForContacts(contactsSelected))
            Mixpanel.sharedInstance().track("Send SMS Server", properties: ["nb_recipients" : getArrayOfNumbersForContacts(contactsSelected).count])
            
        case MessageComposeResultSent.value:
            println("Sent")
            if controller.recipients != nil{
                Mixpanel.sharedInstance().track("Send SMS", properties: ["nb_recipients" : controller.recipients.count])
            }
            else{
                Mixpanel.sharedInstance().track("Send SMS")
            }
            
            
        default:
            break
        }
        
        controller.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.invitingContacts = false
            
            if !self.invitingUsers && !self.invitingContacts{
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                self.goLeave()
            }
        })
        
        
        
        
        
        
    }
    
    func sendSMSToContacts(contacts : Array<APContact>){
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        var phonesArray : Array<String> = Array<String>()
        
        for contact in contacts{
            
            for phone in contact.phones{
                var phoneNumber:String = "\(phone)"
                phonesArray.append(phoneNumber)
            }
            
        }
        
        
        var messageController:MFMessageComposeViewController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.recipients = phonesArray
        messageController.body = String(format: NSLocalizedString("SendInvitSMS", comment : ""), Utils().shareAppUrl)
        
        if Utils().iOS8{
            if MFMessageComposeViewController.respondsToSelector(Selector("canSendAttachments")) && MFMessageComposeViewController.canSendAttachments(){
                messageController.addAttachmentURL(Utils().createGifInvit(PFUser.currentUser()!.username!), withAlternateFilename: "invitationGif.gif")
            }
        }
        else{
            var dataImage:NSData? = UIImagePNGRepresentation(Utils().getShareUsernameImage())
            if dataImage != nil{
                messageController.addAttachmentData(dataImage, typeIdentifier: "image/png", filename: "peekeeInvit.png")
            }
            
        }
        
        self.presentViewController(messageController, animated: true) { () -> Void in
            
        }
        
        
    }
    
    
    // MARK : SEND FROM SERVER
    
    func getArrayOfAllNumbers() -> Array<String>{
        
        var allNumberFormatted:Array<String> = Array<String>()
        
        for contact in contactsPhone{
            
            for phone in contact.phones{
                
                if let phoneNumber = self.getFormattedPhoneNumber(phone as! String){
                    allNumberFormatted.append(phoneNumber)
                }
                
                
                
            }
            
        }
        
        return allNumberFormatted
        
    }
    
    
    func getArrayOfNumbersForContacts(contacts : Array<APContact>) -> Array<String>{
        
        println("Contacts : \(contacts)")
        
        var allNumberFormatted:Array<String> = Array<String>()
        
        for contact in contacts{
            
            for phone in contact.phones{
                
                if let phoneNumber = self.getFormattedPhoneNumber(phone as! String){
                    allNumberFormatted.append(phoneNumber)
                }
                
                
                
            }
            
        }
        
        return allNumberFormatted
    
    
    }
    
    
    func sendSmsFromSeverTo(contactsNumber : Array<String>){
        
        println("Send To : \(contactsNumber)")
        
        var bgTaskIdentifierSendSMS:UIBackgroundTaskIdentifier!
        bgTaskIdentifierSendSMS = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierSendSMS)
            bgTaskIdentifierSendSMS = UIBackgroundTaskInvalid
        })
        
        PFCloud.callFunctionInBackground("sendInviteSMS",
            withParameters: ["phoneNumberTab" : contactsNumber]) { (result, error) -> Void in
                if error != nil {
                    println("Error : \(error!.localizedDescription)")
                }
                
                UIApplication.sharedApplication().endBackgroundTask(bgTaskIdentifierSendSMS)
                bgTaskIdentifierSendSMS = UIBackgroundTaskInvalid
        }
    }
    
    
    
    // MARK: POP UP Contact Autho
    
    func createPopUp(){
        
        if rootPopUpView == nil{
            
            rootOverlay = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            rootOverlay!.backgroundColor = UIColor.blackColor()
            rootOverlay!.alpha = 0.8
            self.view.addSubview(rootOverlay!)
            
            rootPopUpView = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 305))
            rootPopUpView!.center = self.view.center
            rootPopUpView!.backgroundColor = UIColor.whiteColor()
            
            
            var headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: rootPopUpView!.frame.width, height: 48))
            headerView.backgroundColor = Utils().secondColor
            rootPopUpView!.addSubview(headerView)
            
            var headerLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height))
            headerLabel.font = UIFont(name: Utils().customFontSemiBold, size: 20)
            headerLabel.textAlignment = NSTextAlignment.Center
            headerLabel.textColor = UIColor.whiteColor()
            headerLabel.text = NSLocalizedString("Last but not least", comment :"Last but not least")
            headerView.addSubview(headerLabel)
            
            
            var imagePopUp:UIImageView = UIImageView(frame: CGRect(x: 0, y: headerView.frame.height + 5, width: rootPopUpView!.frame.width, height: 135))
            imagePopUp.image = UIImage(named: "popup")
            imagePopUp.contentMode = UIViewContentMode.Center
            rootPopUpView!.addSubview(imagePopUp)
            
            
            let dividerHorizontal:UIView = UIView(frame: CGRect(x: 0, y: 246, width: rootPopUpView!.frame.width, height: 1))
            dividerHorizontal.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            rootPopUpView!.addSubview(dividerHorizontal)
            
            let dividerVertical:UIView = UIView(frame: CGRect(x: rootPopUpView!.frame.width/2, y: 246, width: 1, height: rootPopUpView!.frame.height - 246))
            dividerVertical.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            rootPopUpView!.addSubview(dividerVertical)
            
            let tapGestureQuitPopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUp"))
            let quitImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 246, width: rootPopUpView!.frame.width/2, height: rootPopUpView!.frame.height - 246))
            quitImageView.contentMode = UIViewContentMode.Center
            quitImageView.userInteractionEnabled = true
            quitImageView.image = UIImage(named: "close_popup_icon")
            quitImageView.addGestureRecognizer(tapGestureQuitPopUp)
            rootPopUpView!.addSubview(quitImageView)
            
            let validateAction:UIButton = UIButton(frame: CGRect(x: rootPopUpView!.frame.width/2, y: 246, width: rootPopUpView!.frame.width/2, height: rootPopUpView!.frame.height - 246))
            validateAction.addTarget(self, action: Selector("validateUnlockFriends"), forControlEvents: UIControlEvents.TouchUpInside)
            validateAction.setImage(UIImage(named: "validate_pop_up"), forState: UIControlState.Normal)
            rootPopUpView!.addSubview(validateAction)
            
            let labelPopUp:UILabel = UILabel(frame: CGRect(x: 18, y: 167, width: rootPopUpView!.frame.width - 36, height: 61))
            labelPopUp.numberOfLines = 2
            labelPopUp.textAlignment = NSTextAlignment.Center
            labelPopUp.adjustsFontSizeToFitWidth = true
            labelPopUp.font = UIFont(name: Utils().customFontNormal, size: 24.0)
            labelPopUp.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            labelPopUp.text = NSLocalizedString("Check if you have friends here?!😁", comment : "Check if you have friends here?!😁")
            rootPopUpView!.addSubview(labelPopUp)
            
            self.view.addSubview(rootPopUpView!)
            
            
        }
        
    }
    
    
    //Want access contacts
    func validateUnlockFriends(){
        
        switch APAddressBook.access()
        {
        case APAddressBookAccess.Unknown:
            self.rootOverlay!.hidden = true
            self.rootPopUpView!.hidden = true
            getContacts()
            break
            
        case APAddressBookAccess.Granted:
            self.rootOverlay!.hidden = true
            self.rootPopUpView!.hidden = true
            getContacts()
            break
            
        case APAddressBookAccess.Denied:
            leavePopUp()
            break
        }
    }
    
    func leavePopUp(){
        rootOverlay!.hidden = true
        rootPopUpView!.hidden = true
        //Quit
        goLeave()
        
    }
    
    func goLeave(){
        
        PFUser.currentUser()!["hasSeenFriends"] = true
        PFUser.currentUser()!.saveInBackgroundWithBlock { (finished, error) -> Void in
            Utils().updateUser()
        }
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    
    // MARK Alert View Delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        println("Index  : \(buttonIndex)")
        
        if alertView.tag == 1{
            
            // No Send
            if buttonIndex == 0{
                
            }
            else{
                self.sendSmsFromSeverTo(self.getArrayOfAllNumbers())
                self.goLeave()
            }
            
        }
        
    }
    
}