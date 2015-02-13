//
//  SearchFriendsViewController.swift
//  Piki
//
//  Created by Adrien Dulong on 26/11/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation
import MessageUI
import CoreTelephony

protocol SearchFriendsProtocol {
    func leaveSearchFriends()
}


class ContactPhoneTableViewCell : UITableViewCell {
    
    var nameContactLabel: UILabel!
    var usernameLabel: UILabel!
    var searchController:SearchFriendsViewController?
    var contact:APContact?
    var userInfos:[String : String]?
    var loadIndicator:UIActivityIndicatorView?
    var actionButton:UIButton?
    var moreInfosLabel:UILabel?
    
    
    func loadContact(contact : APContact, searchController : SearchFriendsViewController){
        
        self.searchController = searchController
        self.contact = contact
        
        if actionButton == nil {
            actionButton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 50, y: 0, width: 45, height: 60))
            actionButton!.addTarget(self, action: Selector("inviteContact:"), forControlEvents: UIControlEvents.TouchUpInside)
            contentView.addSubview(actionButton!)
        }
       
        
        actionButton!.setImage(UIImage(named: "sms_not_sent_icon"), forState: UIControlState.Normal)
        
        self.backgroundColor = UIColor.whiteColor()
        
        if nameContactLabel == nil {
            nameContactLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 60))
            nameContactLabel.font = UIFont(name: Utils().customFontSemiBold, size: 22.0)
            nameContactLabel.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            self.addSubview(nameContactLabel)
            
        }
        

        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadIndicator!.tintColor = Utils().secondColor
        loadIndicator!.center = actionButton!.center
        loadIndicator!.hidesWhenStopped = true
        self.addSubview(loadIndicator!)
        
        if moreInfosLabel != nil{
            moreInfosLabel!.hidden = true
            
        }
        
        nameContactLabel.text = contact.compositeName
        
        /*if let phones = contact.phones {
            let array = phones as NSArray
            usernameLabel.text = array.componentsJoinedByString(" ")
        }*/
        
        if userInfos != nil {

            actionButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
            
            if self.searchController!.isUserAlreadyAdded(userInfos!["userObjectId"]! as String){
                actionButton!.setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
            }
        }
        else{
            actionButton!.setImage(UIImage(named: "sms_not_sent_icon"), forState: UIControlState.Normal)
        }
        
    }
    
    func loadUserContact(contactUserInfo : [String : AnyObject], searchController : SearchFriendsViewController){
        self.searchController = searchController
        self.contact = contactUserInfo["contact"] as? APContact
        
        if actionButton == nil {
            actionButton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 50, y: 0, width: 45, height: 60))
            actionButton!.addTarget(self, action: Selector("inviteContact:"), forControlEvents: UIControlEvents.TouchUpInside)
            contentView.addSubview(actionButton!)
        }
        
        
        actionButton!.setImage(UIImage(named: "sms_not_sent_icon"), forState: UIControlState.Normal)
        
        self.backgroundColor = UIColor.whiteColor()
        
        if nameContactLabel == nil {
            nameContactLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 60))
            nameContactLabel.font = UIFont(name: Utils().customFontSemiBold, size: 22.0)
            nameContactLabel.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            self.addSubview(nameContactLabel)
            
        }
        
        if moreInfosLabel == nil{
            moreInfosLabel = UILabel(frame: CGRect(x: 15, y: 40, width: 300, height: 20))
            moreInfosLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 14.0)
            moreInfosLabel!.textColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
            self.addSubview(moreInfosLabel!)
            
        }
        
        moreInfosLabel!.hidden = false
        
        
        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadIndicator!.tintColor = Utils().secondColor
        loadIndicator!.center = actionButton!.center
        loadIndicator!.hidesWhenStopped = true
        self.addSubview(loadIndicator!)
        
        
        nameContactLabel.text = contact!.compositeName
        
        
        userInfos =  contactUserInfo["userInfos"] as? [String : String]
        /*if let phones = contact.phones {
        let array = phones as NSArray
        usernameLabel.text = array.componentsJoinedByString(" ")
        }*/
        
        if userInfos != nil {
            var username:String? = userInfos!["username"]
            moreInfosLabel!.text = "@\(username!)"
            
            actionButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
            
            if self.searchController!.isUserAlreadyAdded(userInfos!["userObjectId"]! as String){
                actionButton!.setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
            }
        }
        else{
            actionButton!.setImage(UIImage(named: "sms_not_sent_icon"), forState: UIControlState.Normal)
        }
    }
    
    /*@IBAction func inviteContact(sender: AnyObject) {
        
        self.searchController!.sendSMSToContacts([self.contact!])
        
    }*/
    
    func inviteContact(button : UIButton){
        
        if userInfos != nil{
            
            
            if !self.searchController!.isUserAlreadyAdded(userInfos!["userObjectId"]! as String){
                
                loadIndicator!.startAnimating()
                
                
                Utils().addFriend(userInfos!["userObjectId"]!).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                    self.loadIndicator!.stopAnimating()
                    if task.error != nil {
                        
                    }
                    else{
                        
                        self.searchController!.getAllUsersFromContacts()
                        self.searchController!.friends.append(task.result as PFUser)
                        self.searchController!.sortFriends()
                        self.searchController!.tableView.reloadData()
                        NSNotificationCenter.defaultCenter().postNotificationName("updateContacts", object: nil)
                        
                        
                        self.searchController!.friendsSelectorLabel!.text = "\(self.searchController!.getNumberOfFriends()) FRIENDS"
                        UIView.animateWithDuration(0.2,
                            animations: { () -> Void in
                                self.searchController!.friendsSelectorLabel!.textColor = Utils().secondColor
                                self.searchController!.friendsSelectorLabel!.transform = CGAffineTransformMakeScale(1.5, 1.5)
                            }, completion: { (finisehd) -> Void in
                                
                                UIView.animateWithDuration(0.2,
                                    animations: { () -> Void in
                                        self.searchController!.friendsSelectorLabel!.transform = CGAffineTransformIdentity
                                        self.searchController!.friendsSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
                                })
                        })
                    }
                    
                    return nil
                })
            }
            
            
        }
        else{
            self.searchController!.sendSMSToContacts([self.contact!])
        }
        
    }
}


class PikiUserTableViewCell : UITableViewCell {
    
    
    
    var usernameLabel: UILabel?
    var addUserButton: UIButton?
    var user:PFUser?
    var loadIndicator:UIActivityIndicatorView?
    var searchController:SearchFriendsViewController?
    
    func loadItem(user : PFUser, searchController : SearchFriendsViewController){
        
        self.searchController = searchController
        
        self.backgroundColor = UIColor.whiteColor()
        
        if usernameLabel == nil {
            usernameLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 60))
            usernameLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 22.0)
            usernameLabel!.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            self.addSubview(usernameLabel!)
            
        }
        
        if addUserButton == nil {
            addUserButton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 50, y: 0, width: 45, height: 60))
            addUserButton!.addTarget(self, action: Selector("addUser:"), forControlEvents: UIControlEvents.TouchUpInside)
            contentView.addSubview(addUserButton!)
        }
        
        addUserButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
        addUserButton!.hidden = false
        
        self.user = user
        
        var username:String = user["username"] as String
        usernameLabel!.text = "@\(username)"
        
        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadIndicator!.center = addUserButton!.center
        loadIndicator!.hidesWhenStopped = true
        self.addSubview(loadIndicator!)
        
        if Utils().isUserAFriend(user){
            addUserButton!.setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
            
        }
        else{
            addUserButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
        }
        
        
        
        
    }
    
    
    func loadItemSearch(contactInfos : [String : AnyObject]){
        
        self.backgroundColor = UIColor.whiteColor()
        
        var username:String = contactInfos["username"] as String
        var isSearching:Bool = contactInfos["searching"] as Bool
        
        if usernameLabel == nil {
            usernameLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 60))
            usernameLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 22.0)
            usernameLabel!.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            self.addSubview(usernameLabel!)
            
        }
        
        
        if addUserButton == nil {
            addUserButton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 50, y: 0, width: 45, height: 60))
            addUserButton!.addTarget(self, action: Selector("addUser:"), forControlEvents: UIControlEvents.TouchUpInside)
            contentView.addSubview(addUserButton!)
        }
        
        addUserButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
        
        addUserButton!.hidden = true
        
        
        //self.user = user
        
        usernameLabel!.text = "@\(username)"
        
        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadIndicator!.center = addUserButton!.center
        loadIndicator!.hidesWhenStopped = true
        self.addSubview(loadIndicator!)
        
        if isSearching{
            loadIndicator!.startAnimating()
        }
        else{
            loadIndicator!.stopAnimating()
        }
        

    }
    
    
    func addUser(sender: UIButton) {
        
        loadIndicator!.startAnimating()
        self.addUserButton!.hidden = true
        
        if Utils().isUserAFriend(user!){
            
            
            Utils().removeFriend(self.user!.objectId).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                self.loadIndicator!.stopAnimating()
                if task.error != nil{
                    
                }
                else{
                    self.addUserButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
                }
                
                self.addUserButton!.hidden = false
                
                return nil
            })
            
        }
        else{
            //Not a friend, friend him
            Utils().addFriend(self.user!.objectId).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                self.loadIndicator!.stopAnimating()
                if task.error != nil{
                    
                }
                else{
                    
                    self.searchController!.getAllUsersFromContacts()
                    self.searchController!.friends.append(task.result as PFUser)
                    self.searchController!.sortFriends()
                    self.searchController!.tableView.reloadData()
                    NSNotificationCenter.defaultCenter().postNotificationName("updateContacts", object: nil)
                    
                    
                    self.searchController!.friendsSelectorLabel!.text = "\(self.searchController!.getNumberOfFriends()) FRIENDS"
                    UIView.animateWithDuration(0.2,
                        animations: { () -> Void in
                            self.searchController!.friendsSelectorLabel!.textColor = Utils().secondColor
                            self.searchController!.friendsSelectorLabel!.transform = CGAffineTransformMakeScale(1.5, 1.5)
                        }, completion: { (finisehd) -> Void in
                            
                            UIView.animateWithDuration(0.2,
                                animations: { () -> Void in
                                    self.searchController!.friendsSelectorLabel!.transform = CGAffineTransformIdentity
                                    self.searchController!.friendsSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
                            })
                    })
                    
                    self.addUserButton!.setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
                }
                
                self.addUserButton!.hidden = false
                
                return nil
                
            })
            
        }

    }
    
}

class SearchFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTopBarView: UIView!
    @IBOutlet weak var typeFriendsSelectorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var cancelSearchButton:UIButton?
    
    
    @IBOutlet weak var topRightViewBar: UIView!
    
    var pikiUsersFound:Array<AnyObject> = []
    var contactsPhone:Array<APContact> = []
    var sortedContactsPhone:Array<APContact> = []
    var usersWhoAddedMe:Array<PFUser> = []
    var usersIAlreadyAddedFriendship:Array<PFUser> = []
    var friends:Array<PFUser> = []
    
    let addressBook = APAddressBook()
    var pikiUsersFromPhoneContacts:Array<[String : String]> = Array<[String : String]>()
    var contactsWithUserInfos:Array<[String : AnyObject]> = Array<[String : AnyObject]>()
    var regionLabel:String?
    
    var findSelectorLabel:UILabel?
    var friendsSelectorLabel:UILabel?
    var indicatorView:UIView?
    
    var printMode = 0
    var delegate:SearchFriendsProtocol? = nil
    
    var unlockContactsBar:UIView?
    var firstUserUnlock:Bool?
    
    var lookingForFriendsOnPeekee:Bool = false
    var isLoadingMore:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let backStatusBar:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        backStatusBar.backgroundColor = Utils().statusBarColor
        self.view.addSubview(backStatusBar)
        
        tableView.backgroundColor = UIColor.whiteColor()
        topRightViewBar!.backgroundColor = Utils().primaryColorDark
        
        cancelSearchButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 80, y: 22, width: 70, height: 40))
        cancelSearchButton!.setTitle("Cancel", forState: UIControlState.Normal)
        cancelSearchButton!.setTitleColor(Utils().greyColor, forState: UIControlState.Normal)
        cancelSearchButton!.titleLabel?.font = UIFont(name: Utils().customFont, size: 18.0)
        cancelSearchButton!.addTarget(self, action: Selector("cancelSearch:"), forControlEvents: UIControlEvents.TouchUpInside)
        cancelSearchButton!.hidden = true
        //self.view.addSubview(cancelSearchButton!)
        
        searchTopBarView.backgroundColor = Utils().primaryColor
        typeFriendsSelectorView.backgroundColor = UIColor.whiteColor()
        
        searchTextField.backgroundColor = Utils().primaryColor
        searchTextField.delegate = self
        searchTextField.placeholder = NSLocalizedString("Search a user", comment : "Search a user")
        searchTextField.textColor = UIColor.whiteColor()
        searchTextField.font = UIFont(name: Utils().customFontSemiBold, size: 22.0)
        //searchTextField.addTarget(self, action: Selector("changedText:"), forControlEvents: UIControlEvents.EditingChanged)
        searchTextField.returnKeyType = UIReturnKeyType.Search
        searchTextField.keyboardAppearance = UIKeyboardAppearance.Light
      
        
        //Unlock bar if user doid not authorize access contacts
        let tapToUnlockGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("unlockFriendsAfterTap"))
        unlockContactsBar = UIView(frame: CGRect(x: 0, y: 130, width: self.view.frame.width, height: 55))
        unlockContactsBar!.addGestureRecognizer(tapToUnlockGesture)
        unlockContactsBar!.alpha = 0.0
        unlockContactsBar!.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        self.view.addSubview(unlockContactsBar!)
        let iconUnlock:UIImageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 38, height: unlockContactsBar!.frame.height))
        iconUnlock.contentMode = UIViewContentMode.Center
        iconUnlock.image = UIImage(named: "unlock_friends_icon")
        unlockContactsBar!.addSubview(iconUnlock)
        let labelUnlock:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: unlockContactsBar!.frame.width, height: unlockContactsBar!.frame.height))
        labelUnlock.font = UIFont(name: Utils().customFontSemiBold, size: 18.0)
        labelUnlock.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
        labelUnlock.textAlignment = NSTextAlignment.Center
        labelUnlock.text = "TAP TO UNLOCK FRIENDS"
        unlockContactsBar!.addSubview(labelUnlock)
        
        
        typeFriendsSelectorView.frame = CGRect(x: 0, y: 80, width: self.view.frame.width, height: 50)
        
        var leftViewSearch:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: searchTextField.frame.size.height))
        var loupeImageView:UIImageView = UIImageView(frame: CGRect(x: leftViewSearch.frame.size.width/2 - 6, y: leftViewSearch.frame.size.height/2 - 6, width: 16, height: 16))
        loupeImageView.image = UIImage(named: "search_icon")
        leftViewSearch.addSubview(loupeImageView)
        searchTextField.leftView = leftViewSearch
        searchTextField.leftViewMode = UITextFieldViewMode.Always
        
        
        
        
        var gestureFindSelection:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("findSelection:"))
        let findSelectorView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.typeFriendsSelectorView.frame.width/2, height: self.typeFriendsSelectorView.frame.height))
        findSelectorView.backgroundColor = UIColor.whiteColor()
        findSelectorView.addGestureRecognizer(gestureFindSelection)
        typeFriendsSelectorView.addSubview(findSelectorView)
        
        findSelectorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: findSelectorView.frame.width, height: findSelectorView.frame.height))
        findSelectorLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 18)
        findSelectorLabel!.textColor = Utils().primaryColor
        findSelectorLabel!.text = NSLocalizedString("FIND", comment : "FIND")
        findSelectorLabel!.textAlignment = NSTextAlignment.Center
        findSelectorView.addSubview(findSelectorLabel!)
        
        var gestureFriendsSelection:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("friendsSelection:"))
        let friendsSelectorView:UIView = UIView(frame: CGRect(x: self.typeFriendsSelectorView.frame.width/2, y: 0, width: self.typeFriendsSelectorView.frame.width/2, height: self.typeFriendsSelectorView.frame.height))
        friendsSelectorView.backgroundColor = UIColor.whiteColor()
        friendsSelectorView.addGestureRecognizer(gestureFriendsSelection)
        typeFriendsSelectorView.addSubview(friendsSelectorView)
        
        friendsSelectorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: friendsSelectorView.frame.width, height: friendsSelectorView.frame.height))
        friendsSelectorLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 18)
        friendsSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
        let nbFriendsFormat = String(format: NSLocalizedString("%d FRIENDS", comment : "%d FRIENDS"), getNumberOfFriends())
        friendsSelectorLabel!.text = nbFriendsFormat
        friendsSelectorLabel!.textAlignment = NSTextAlignment.Center
        friendsSelectorLabel!.adjustsFontSizeToFitWidth = true
        friendsSelectorView.addSubview(friendsSelectorLabel!)
        
        indicatorView = UIView(frame: CGRect(x: 0, y: typeFriendsSelectorView!.frame.height - 2, width: typeFriendsSelectorView!.frame.width/2, height: 2))
        indicatorView!.backgroundColor = Utils().secondColor
        typeFriendsSelectorView!.addSubview(indicatorView!)
        
        
        //Shadow for bottom button
        var stretchShadowImage:UIImage = UIImage(named: "shadow_top")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        let shadowImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: typeFriendsSelectorView.frame.origin.y + typeFriendsSelectorView.frame.size.height , width: UIScreen.mainScreen().bounds.width, height: 4))
        shadowImageView.image = stretchShadowImage
        self.view.addSubview(shadowImageView)
        
        
        
        //We arrive first time in the view
        if firstUserUnlock != nil{
            //User accept to unlock friends
            if firstUserUnlock!{
                unlockFriends()
            }
            else{
                showBarUnlockCOntacts()
            }
            
        }
        else{
            //Utils().viewUnlockFriend()
            showBarUnlockCOntacts()
            
        }
        
        
        
        //Get friends in the app
        getFriends()
        
        
        
    }
    
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    
    /*
    * Table View
    */
    

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 61
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if printMode == 0 {
            var nbSection:Int = 1
            
            if pikiUsersFound.count > 0{
                nbSection++
            }
            
            if contactsWithUserInfos.count > 0{
                nbSection++
            }
            
            if self.lookingForFriendsOnPeekee{
                nbSection++
            }
            

            return nbSection
        }
        else{
            return 1
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if printMode == 0 {
            if section == 0{
                if pikiUsersFound.count > 0{
                    return pikiUsersFound.count
                }
                else if contactsWithUserInfos.count > 0{
                    return contactsWithUserInfos.count
                }
                else if self.lookingForFriendsOnPeekee{
                    return 0
                }
                else{
                    return sortedContactsPhone.count
                }
            }
            else if section == 1{
                if self.lookingForFriendsOnPeekee{
                    return 0
                }
                else if pikiUsersFound.count > 0{
                    if contactsWithUserInfos.count > 0{
                        return contactsWithUserInfos.count
                    }
                    else{
                        return sortedContactsPhone.count
                    }
                }
                else{
                    return sortedContactsPhone.count
                }
                
            }
            else{
                return sortedContactsPhone.count
            }
        }
        else{
            return friends.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if printMode == 0{
            if indexPath.section == 0{
                if pikiUsersFound.count > 0{
                    var cell:PikiUserTableViewCell = tableView.dequeueReusableCellWithIdentifier("PikiUserCell") as PikiUserTableViewCell
                    
                    if pikiUsersFound[indexPath.row].isKindOfClass(PFUser){
                        println("USER")
                        cell.loadItem(pikiUsersFound[indexPath.row] as PFUser, searchController: self)
                    }
                    else{
                        cell.loadItemSearch(pikiUsersFound[indexPath.row] as [String : AnyObject])
                    }
                    
                    
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    return cell
                }
                else if contactsWithUserInfos.count > 0{
                    var cellContact:ContactPhoneTableViewCell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as ContactPhoneTableViewCell
                    
                    var contactUserInfo = contactsWithUserInfos[indexPath.row]
                    
                    
                    
                    cellContact.loadUserContact(contactUserInfo, searchController: self)
                    cellContact.selectionStyle = UITableViewCellSelectionStyle.None
                    return cellContact
                }
                else{
                    var cellContact:ContactPhoneTableViewCell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as ContactPhoneTableViewCell
                    
                    cellContact.userInfos = nil
                    cellContact.loadContact(sortedContactsPhone[indexPath.row], searchController: self)
                    cellContact.selectionStyle = UITableViewCellSelectionStyle.None
                    return cellContact
                }
                
            }
            else if indexPath.section == 1{
                
                if pikiUsersFound.count > 0{
                    if contactsWithUserInfos.count > 0{
                        var cellContact:ContactPhoneTableViewCell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as ContactPhoneTableViewCell
                        
                        var contactUserInfo = contactsWithUserInfos[indexPath.row]
                        cellContact.userInfos = contactUserInfo["userInfos"] as? [String : String]
                        
                        cellContact.loadContact(contactUserInfo["contact"] as APContact, searchController: self)
                        cellContact.selectionStyle = UITableViewCellSelectionStyle.None
                        return cellContact
                    }
                    else{
                        var cellContact:ContactPhoneTableViewCell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as ContactPhoneTableViewCell
                        
                        cellContact.userInfos = nil
                        cellContact.loadContact(sortedContactsPhone[indexPath.row], searchController: self)
                        cellContact.selectionStyle = UITableViewCellSelectionStyle.None
                        return cellContact
                    }
                    
                }
                else{
                    var cellContact:ContactPhoneTableViewCell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as ContactPhoneTableViewCell
                    
                    cellContact.userInfos = nil
                    cellContact.loadContact(sortedContactsPhone[indexPath.row], searchController: self)
                    cellContact.selectionStyle = UITableViewCellSelectionStyle.None
                    return cellContact
                }
            }
            else{
                var cellContact:ContactPhoneTableViewCell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as ContactPhoneTableViewCell
                
                cellContact.userInfos = nil
                cellContact.loadContact(sortedContactsPhone[indexPath.row], searchController: self)
                cellContact.selectionStyle = UITableViewCellSelectionStyle.None
                return cellContact
            }
        }
        else{
            var cell:PikiUserTableViewCell = tableView.dequeueReusableCellWithIdentifier("PikiUserCell") as PikiUserTableViewCell
            cell.loadItem(friends[indexPath.row], searchController: self)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            
            if indexPath.row == (friends.count - 10){
                if friends.count > 0 && !isLoadingMore{
                    if friends.count % 100 == 0{
                        println("Load More")
                        isLoadingMore = true
                        getMoreFriends()
                    }
                }
            }
            
            
            
            return cell
            
            
        }

    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if printMode == 0{
            
            if self.lookingForFriendsOnPeekee{
                if section == 0{
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
        else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var viewHeader:UIView = UIView(frame: CGRect(x: 15, y: 0, width: self.view.frame.size.width, height: 32))
        viewHeader.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        
        var backLabel = UIView(frame: CGRect(x: 0, y: 0, width: viewHeader.frame.width, height: 32))
        backLabel.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        viewHeader.addSubview(backLabel)
        
        var labelHeader:UILabel = UILabel(frame: CGRect(x: 10, y: 0, width: viewHeader.frame.size.width, height: 32))
        labelHeader.font = UIFont(name: Utils().customFontSemiBold, size: 16.0)
        labelHeader.textColor = UIColor.whiteColor()
        
        var gesture:UITapGestureRecognizer?
        
        if printMode == 0{
            if section == 0{
                if pikiUsersFound.count > 0 {
                    labelHeader.text = NSLocalizedString("PEEKEE USER", comment : "PEEKEE USER")
                }
                else if contactsWithUserInfos.count > 0{
                    labelHeader.text = NSLocalizedString("FRIENDS ON PEEKEE", comment : "FRIENDS ON PEEKEE")
                }
                else if self.lookingForFriendsOnPeekee{
                    
                    labelHeader.text = NSLocalizedString("LOOKING FOR FRIENDS", comment : "LOOKING FOR FRIENDS")
                    viewHeader.backgroundColor = Utils().secondColor
                    labelHeader.textAlignment = NSTextAlignment.Center
                    viewHeader.frame = CGRect(x: 15, y: 0, width: self.view.frame.size.width, height: 64)
                    
                    backLabel.backgroundColor = Utils().secondColor
                    
                    var loadIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
                    loadIndicator.tintColor = UIColor.whiteColor()
                    loadIndicator.center = CGPoint(x: viewHeader.frame.width/2, y: viewHeader.frame.height/2 + viewHeader.frame.height/4 - 3)
                    loadIndicator.hidesWhenStopped = true
                    loadIndicator.startAnimating()
                    viewHeader.addSubview(loadIndicator)
                }
                else{
                    labelHeader.text = NSLocalizedString("FRIENDS NOT YET ON PEEKEE", comment : "FRIENDS NOT YET ON PEEKEE")
                }
                
            }
            else if section == 1{
                if pikiUsersFound.count > 0 {
                    if contactsWithUserInfos.count > 0{
                        labelHeader.text = NSLocalizedString("FRIENDS ON PEEKEE", comment : "FRIENDS ON PEEKEE")
                    }
                    else if self.lookingForFriendsOnPeekee{
                        
                        labelHeader.text = NSLocalizedString("LOOKING FOR FRIENDS", comment : "LOOKING FOR FRIENDS")
                        viewHeader.backgroundColor = Utils().secondColor
                        labelHeader.textAlignment = NSTextAlignment.Center
                        viewHeader.frame = CGRect(x: 15, y: 0, width: self.view.frame.size.width, height: 64)
                        
                        backLabel.backgroundColor = Utils().secondColor
                        
                        var loadIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
                        loadIndicator.tintColor = UIColor.whiteColor()
                        loadIndicator.center = CGPoint(x: viewHeader.frame.width/2, y: viewHeader.frame.height/2 + viewHeader.frame.height/4 - 3)
                        loadIndicator.hidesWhenStopped = true
                        loadIndicator.startAnimating()
                        viewHeader.addSubview(loadIndicator)
                    }
                    else{
                        labelHeader.text = NSLocalizedString("FRIENDS NOT YET ON PEEKEE", comment : "FRIENDS NOT YET ON PEEKEE")
                    }
                }
                else{
                    labelHeader.text = NSLocalizedString("FRIENDS NOT YET ON PEEKEE", comment : "FRIENDS NOT YET ON PEEKEE")
                }
                /*
                
                if contactsWithUserInfos.count > 0{
                    labelHeader.text = NSLocalizedString("FRIENDS ON PEEKEE", comment : "FRIENDS ON PEEKEE")
                }
                else if self.lookingForFriendsOnPeekee{
                    
                    labelHeader.text = NSLocalizedString("LOOKING FOR FRIENDS", comment : "LOOKING FOR FRIENDS")
                    viewHeader.backgroundColor = Utils().secondColor
                    labelHeader.textAlignment = NSTextAlignment.Center
                    viewHeader.frame = CGRect(x: 15, y: 0, width: self.view.frame.size.width, height: 64)
                    
                    backLabel.backgroundColor = Utils().secondColor
                    
                    var loadIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
                    loadIndicator.tintColor = UIColor.whiteColor()
                    loadIndicator.center = CGPoint(x: viewHeader.frame.width/2, y: viewHeader.frame.height/2 + viewHeader.frame.height/4 - 3)
                    loadIndicator.hidesWhenStopped = true
                    loadIndicator.startAnimating()
                    viewHeader.addSubview(loadIndicator)
                }
                else{
                    labelHeader.text = NSLocalizedString("FRIENDS NOT YET ON PEEKEE", comment : "FRIENDS NOT YET ON PEEKEE")
                }*/
            }
            else{
                labelHeader.text = NSLocalizedString("FRIENDS NOT YET ON PEEKEE", comment : "FRIENDS NOT YET ON PEEKEE")
            }
        }
        else{
            labelHeader.text = NSLocalizedString("FRIENDS", comment : "FRIENDS")
        }
        
        
        backLabel.addSubview(labelHeader)

        
        return viewHeader
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    /*
    * TextField Delegate
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        if printMode == 1{
            printMode = 0
            self.tableView.reloadData()
            
            UIView.animateWithDuration(0.4,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 10.0,
                options: nil,
                animations: { () -> Void in
                    self.findSelectorLabel!.textColor = Utils().primaryColor
                    self.friendsSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
                    self.indicatorView!.transform = CGAffineTransformIdentity
                }) { (finished) -> Void in
                    println("Show Find")
                    
            }
        }
        
        var finalText:NSString = textField.text as NSString
        finalText = finalText.stringByReplacingCharactersInRange(range, withString: string).lowercaseString
        
        var textLessWhite:String = finalText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString
        
        pikiUsersFound.removeAll(keepCapacity: false)
        
        if countElements(textLessWhite) > 0{
            if countElements(textLessWhite) > 1 {
                var contactInfo = ["username" : textLessWhite, "searching" : true]
                pikiUsersFound.append(contactInfo)
            }
            else{
                var contactInfo = ["username" : textLessWhite, "searching" : false]
                pikiUsersFound.append(contactInfo)
            }
            
        }
        
        
        self.tableView.reloadData()
        
        
        
        if countElements(textLessWhite) > 1 {
            
            //Sort phone Contacts
            if printMode == 0{
                
                
                
                sortedContactsPhone.removeAll(keepCapacity: false)
                
                for contact in contactsPhone{
                    if contact.compositeName != nil {
                        var stringName:NSString = NSString(string: contact.compositeName.lowercaseString)
                        if stringName.rangeOfString(textLessWhite).length > 0{
                            sortedContactsPhone.append(contact)
                        }
                    }
                    
                }
                
                tableView.reloadData()
            }
            
            
            
            getUserWithUsername(textLessWhite).continueWithBlock { (task : BFTask!) -> AnyObject! in
                if task.error != nil{
                    
                }
                else{
                    if task.result.count > 0{
                        var users:Array<PFUser> = task.result as Array<PFUser>
                        println("\(users)")
                        self.pikiUsersFound = users
                        self.tableView.reloadData()
                    }
                    else{
                        self.pikiUsersFound.removeAll(keepCapacity: false)
                        var contactInfo = ["username" : textLessWhite, "searching" : false]
                        self.pikiUsersFound.append(contactInfo)
                        self.tableView.reloadData()
                    }
                    
                    
                }
                
                return nil
            }
            
        }
        else{
            sortedContactsPhone = contactsPhone
            self.tableView.reloadData()
        }
        
        return true
    }
    
    func changedText(sender : UITextField){
        
        
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return false
    }
    
    
    /*
    * Interactions
    */
    
    @IBAction func quitSearch(sender: AnyObject) {

        
        self.navigationController!.popViewControllerAnimated(true)
        
        if delegate != nil{
            self.delegate!.leaveSearchFriends()
        }
        
    }
    
    func cancelSearch(sender : UIButton){
        
        sortedContactsPhone = contactsPhone
        searchTextField.text = ""
        
        pikiUsersFound.removeAll()
        tableView.reloadData()
        
        searchTextField.resignFirstResponder()
        cancelSearchButton!.hidden = true
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.searchTextField.frame = CGRect(x: 50, y: self.searchTextField.frame.origin.y, width: self.view.frame.size.width - 100, height: self.searchTextField.frame.size.height)
            self.searchTextField.layer.cornerRadius = 15
        }) { (finished) -> Void in
            self.quitButton.hidden = false
            self.settingsButton.hidden = false
        }
        
    }
    
    @IBAction func changeSelection(sender: AnyObject) {
        tableView.reloadData()
    }
    
    /*
    * Server functions
    */
    
    func getUserWithUsername(username : String) -> BFTask{
        var successful = BFTaskCompletionSource()
        
        
        var userQuery:PFQuery = PFUser.query()
        userQuery.whereKey("username", equalTo: username)
        userQuery.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
            if error == nil {
                successful.setResult(users)
            }
            else{
                successful.setError(error)
            }
        })
        
        return successful.task
    }
    
    
    
    //GET ALL USER FRIENDS
    func getFriends(){
        
        var arrayFriendsId:Array<String>? = PFUser.currentUser()["usersFriend"] as? Array<String>
        
        if arrayFriendsId != nil{
            var queryFriends:PFQuery = PFUser.query()
            queryFriends.whereKey("objectId", containedIn: arrayFriendsId!)
            queryFriends.orderByAscending("username")
            queryFriends.cachePolicy = kPFCachePolicyCacheThenNetwork
            queryFriends.limit = 100
            
            queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
                if error != nil {
                    
                }
                else{
                    self.friends = friends as Array<PFUser>
                    
                    if self.printMode == 1{
                        self.tableView.reloadData()
                    }
                    
                }
            }
        }

    }
    
    func getMoreFriends(){
        
        
        var arrayFriendsId:Array<String>? = PFUser.currentUser()["usersFriend"] as? Array<String>
        
        
        if arrayFriendsId != nil {
            var queryFriends:PFQuery = PFUser.query()
            queryFriends.whereKey("objectId", containedIn: arrayFriendsId!)
            queryFriends.orderByAscending("username")
            queryFriends.limit = 100
            queryFriends.skip = friends.count
            
            queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
                if error != nil {
                    
                }
                else{
                    
                    var indexPathToInsert:Array<NSIndexPath> = Array<NSIndexPath>()
                    
                    for friend in friends as Array<PFUser>{
                        self.friends.append(friend)
                        indexPathToInsert.append(NSIndexPath(forRow: self.friends.count - 1, inSection: 0))
                    }
                    
                    if self.printMode == 1{
                        self.tableView.insertRowsAtIndexPaths(indexPathToInsert, withRowAnimation: UITableViewRowAnimation.Fade)
                    }
                    
                    self.isLoadingMore = false
                    
                }
            }
        }
        
    }

    
    func checkContactsOnPiki(){
        
        var phoneNumbers:Array<String> = []
        
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        
        
        
        let phoneUtil:NBPhoneNumberUtil = NBPhoneNumberUtil.sharedInstance()
        
        
        
        for contact in self.contactsPhone{
            
            for tel in contact.phones{
                
                if (tel as? String) != nil {
                    
                    if countElements(tel as String) > 6{
                        var errorPointer:NSError?
                        var number:NBPhoneNumber? = phoneUtil.parse(tel as String, defaultRegion:regionLabel!, error:&errorPointer)
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
                println("Error getting piki Users : \(error.localizedDescription)")
                self.lookingForFriendsOnPeekee = false
                self.tableView.reloadData()
            }
            else{
                self.pikiUsersFromPhoneContacts = pikiUsers as Array<[String : String]>
                self.getAllUsersFromContacts()
            }
        }
        
    }
    
    
    /*
    * Utils Functions
    */
    
    func getAllUsersFromContacts(){
        
        dispatch_async(dispatch_get_global_queue(0, 0), {
            var tempContactsWithUserInfos:Array<[String : AnyObject]> = Array<[String : AnyObject]>()
            
            
            var friendsUser:Array<String>? = PFUser.currentUser()["usersFriend"] as? Array<String>
            
            
            if friendsUser == nil{
                friendsUser = []
            }
            
            for userInfos in self.pikiUsersFromPhoneContacts{
                
                if  !contains(friendsUser!, userInfos["userObjectId"]!){
                    
                    for contact in self.contactsPhone{
                        
                        for phone in contact.phones{
                            
                            let formatedPhone:String? = self.getFormattedPhoneNumber(phone as String)
                            if  formatedPhone != nil {
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
    
    func sortFriends(){
        
        self.friends.sort({ $0.username < $1.username})
        
    }
    
    func getFormattedPhoneNumber(numberString : String) -> String? {
        var finalPhoneNumber:String?
        
        
        let phoneUtil:NBPhoneNumberUtil = NBPhoneNumberUtil.sharedInstance()
        var errorPointer:NSError?
        
        if countElements(numberString) > 4{
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
    
    func getUserOfContacts(contact : APContact) -> [String : String]? {
        
        for userInfos in pikiUsersFromPhoneContacts{
            
            for phone in contact.phones{
                
                if getFormattedPhoneNumber(phone as String) != nil {
                    if userInfos["phoneNumber"] == getFormattedPhoneNumber(phone as String){
                        return userInfos
                    }
                }
                
            }

        }
        
        return nil
    }
    
    
    func isUserAlreadyAdded(user : PFUser) -> Bool{
        
        for userId in PFUser.currentUser()["usersFriend"] as Array<String>{
            if user.objectId == userId{
                
                return true
            }
        }
        
        return false
        
    }
    
    func isUserAlreadyAdded(idUser : String) -> Bool{
        
        for userId in PFUser.currentUser()["usersFriend"] as Array<String>{
            if idUser == userId{
                
                return true
            }
        }
        
        return false
        
    }

    
    func getUserAlreadyAdded(user : PFUser) -> PFObject{
        
        var friendToReturn:PFObject?
        
        for friendsAdded in usersIAlreadyAddedFriendship{
            var userFriend:PFUser = friendsAdded
            if userFriend.objectId == user.objectId {
                return friendsAdded
            }
        }
        
        
        return friendToReturn!
    }
    
    
    
    /*
    * Message Composer delegate
    */
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch (result.value) {
        case MessageComposeResultCancelled.value:
            println("Canceled")
            
        case MessageComposeResultFailed.value:
            println("Failed")
            
        case MessageComposeResultSent.value:
            println("Sent")
            
        default:
            break
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        
        
        
    }
    
    func sendSMSToContacts(contacts : Array<APContact>){
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        var messageController:MFMessageComposeViewController = MFMessageComposeViewController()
        messageController.messageComposeDelegate = self
        messageController.recipients = [contacts[0].phones[0]]
        messageController.body = String(format: NSLocalizedString("SendInvitSMS", comment : ""), Utils().shareAppUrl)
        
        if MFMessageComposeViewController.respondsToSelector(Selector("canSendAttachments")) && MFMessageComposeViewController.canSendAttachments(){
            messageController.addAttachmentURL(Utils().createGifInvit(PFUser.currentUser().username), withAlternateFilename: "invitationGif.gif")
        }

        self.presentViewController(messageController, animated: true) { () -> Void in
            
        }
        
        
    }

    @IBAction func goSettings(sender: AnyObject) {

        
    }
    
    func findSelection(gesture : UITapGestureRecognizer){
        
        printMode = 0
        self.tableView.reloadData()
        
        UIView.animateWithDuration(0.4,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 10.0,
            options: nil,
            animations: { () -> Void in
                self.findSelectorLabel!.textColor = Utils().primaryColor
                self.friendsSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
                self.indicatorView!.transform = CGAffineTransformIdentity
            }) { (finished) -> Void in
                println("Show Find")
                
        }
        
    }
    
    
    func friendsSelection(gesture : UITapGestureRecognizer){
        
        printMode = 1
        self.tableView.reloadData()
        
        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 10.0,
            options: nil,
            animations: { () -> Void in
                self.friendsSelectorLabel!.textColor = Utils().primaryColor
                self.findSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
                self.indicatorView!.transform = CGAffineTransformMakeTranslation(self.view.frame.width/2, 0)
        }) { (finished) -> Void in
            println("Show Friends")
            
        }
        
    }
    
    
    // MARK: FIRST USE UNLOCK CONTACTS
    
    func showBarUnlockCOntacts(){
        
        switch APAddressBook.access()
        {
        case APAddressBookAccess.Unknown:
            UIView.animateWithDuration(0.4,
                animations: { () -> Void in
                    self.unlockContactsBar!.alpha = 1.0
            })
            break
            
        case APAddressBookAccess.Granted:
            getContacts()
            break
            
        case APAddressBookAccess.Denied:
            UIView.animateWithDuration(0.4,
                animations: { () -> Void in
                    self.unlockContactsBar!.alpha = 1.0
            })
            break
        }
        
        
        
        
    }
    
    func removeUnlockContactsBar(){
        
        UIView.animateWithDuration(0.4,
            animations: { () -> Void in
                self.unlockContactsBar!.alpha = 0.0
        })
    }
    
    
    func unlockFriends(){
        switch APAddressBook.access()
        {
        case APAddressBookAccess.Unknown:
            getContacts()
            break
            
        case APAddressBookAccess.Granted:
            getContacts()
            break
            
        case APAddressBookAccess.Denied:
            showBarUnlockCOntacts()
            break
        }
    }
    
    func unlockFriendsAfterTap(){
        
        switch APAddressBook.access()
        {
        case APAddressBookAccess.Unknown:
            getContacts()
            break
            
        case APAddressBookAccess.Granted:
            getContacts()
            break
            
        case APAddressBookAccess.Denied:
            // Access denied or restricted by privacy settings
            // TODO : Say to the user to grant access in settings
            break
        }
        
        removeUnlockContactsBar()
        
    }
    
    
    func getContacts(){
        //Contacts
        self.addressBook.fieldsMask = APContactField.All
        self.addressBook.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true),
            NSSortDescriptor(key: "lastName", ascending: true)]
        self.addressBook.filterBlock = {(contact: APContact!) -> Bool in
            return contact.phones.count > 0
        }
        self.addressBook.loadContacts(
            { (contacts: [AnyObject]!, error: NSError!) in
                //self.activity.stopAnimating()
                if (contacts != nil) {
                    //self.memoryStorage().addItems(contacts)
                    //println("Contacts : \(contacts)")
                    self.contactsPhone = contacts as Array<APContact>
                    self.sortedContactsPhone = contacts as Array<APContact>
                    
                    if self.printMode == 0{
                        self.lookingForFriendsOnPeekee = true
                        self.tableView.reloadData()
                    }
                    
                    
                    
                    self.checkContactsOnPiki()
                }
                else if (error != nil) {
                    let alert = UIAlertView(title: "Error", message: error.localizedDescription,
                        delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
        })
    }
    
    
    func getNumberOfFriends() -> Int{
    
        let user:PFUser = PFUser.currentUser()
        let friendsUser : Array<String> = PFUser.currentUser()["usersFriend"] as Array<String>
        
        return friendsUser.count
    
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        
        return true
    }
}
