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

class SearchFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var searchTopBarView: UIView!
    @IBOutlet weak var typeFriendsSelectorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var pikiUsersFound:Array<AnyObject> = []
    var contactsPhone:Array<APContact> = []
    var sortedContactsPhone:Array<APContact> = []
    var usersWhoAddedMe:Array<PFUser> = []
    var usersIAlreadyAddedFriendship:Array<PFUser> = []
    
    
    let addressBook = APAddressBook()
    var pikiUsersFromPhoneContacts:Array<[String : String]> = Array<[String : String]>()
    var contactsWithUserInfos:Array<[String : AnyObject]> = Array<[String : AnyObject]>()
    var regionLabel:String?

    
    var delegate:SearchFriendsProtocol? = nil
    var unlockContactsBar:UIView?
    var firstUserUnlock:Bool?
    var lookingForFriendsOnPeekee:Bool = false
    var headerLabel:UILabel!
    
    //Friends
    var friends:Array<PFUser> = []
    var isLoadingMore:Bool = false
    
    //Recipients
    var recipients:Array<PFUser> = []
    var isLoadingMoreRecipients:Bool = false
    
    //SEARCH
    var searchButton:UIButton!
    var cancelSearchButton:UIButton?
    var searchTextField: UITextField!
    var searchLayer:UIView!
    var backgroundSearchLayer:UIView!
    var searchTableView:UITableView!
    var usernameInSearch:String?
    var usernameUserFound:PFUser?
    var isSearchingUser:Bool = false
    
    //TABS
    var printMode = 0
    var findSelectorLabel:UILabel?
    var friendsSelectorLabel:UILabel?
    var friendsSelectorLabelBottom:UILabel!
    var recipientsSelectorLabel:UILabel?
    var recipientsSelectorLabelBottom:UILabel!
    var indicatorView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        if carrier != nil {
            regionLabel = carrier.isoCountryCode
        }
        else {
            regionLabel = "us"
        }
        
        if regionLabel == nil {
            regionLabel = "us"
        }
        
        let backStatusBar:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        backStatusBar.backgroundColor = Utils().statusBarColor
        self.view.addSubview(backStatusBar)
        
        tableView.backgroundColor = UIColor.whiteColor()
        
        //TopBar Main Label
        headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: searchTopBarView.frame.height))
        headerLabel.textAlignment = NSTextAlignment.Center
        headerLabel.font = UIFont(name: Utils().customFontSemiBold, size: 24.0)
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.text = LocalizedString("Friends")
        searchTopBarView.addSubview(headerLabel)
        
        //Cancel the search button
        cancelSearchButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 40, y: 0, width: 40, height: searchTopBarView.frame.height))
        cancelSearchButton!.setImage(UIImage(named: "quit_search"), forState: UIControlState.Normal)
        cancelSearchButton!.addTarget(self, action: Selector("cancelSearch:"), forControlEvents: UIControlEvents.TouchUpInside)
        cancelSearchButton!.hidden = true
        searchTopBarView.addSubview(cancelSearchButton!)
        
        searchTopBarView.backgroundColor = Utils().primaryColor
        typeFriendsSelectorView.backgroundColor = UIColor.whiteColor()
        
        //Set the search button
        searchButton = UIButton(frame: CGRect(x: self.view.frame.width - 60, y: 0, width: 40, height: searchTopBarView.frame.height))
        searchButton.setImage(UIImage(named: "search_icon"), forState: UIControlState.Normal)
        searchButton!.setImage(UIImage(named: "search_icon"), forState: UIControlState.Disabled)
        searchButton.addTarget(self, action: Selector("enterSearch"), forControlEvents: UIControlEvents.TouchUpInside)
        searchTopBarView.addSubview(searchButton)
        
        //Search Text Field
        var xPositionTextField:CGFloat = self.searchButton.frame.width + 10
        searchTextField = UITextField(frame: CGRect(x: xPositionTextField, y: 0, width: self.view.frame.width - xPositionTextField - 40, height: searchTopBarView.frame.height))
        searchTextField.hidden = true
        searchTextField.backgroundColor = Utils().primaryColor
        searchTextField.autocapitalizationType = UITextAutocapitalizationType.None
        searchTextField.delegate = self
        searchTextField.tintColor = Utils().secondColor
        searchTextField.placeholder = LocalizedString("username")
        searchTextField.textColor = UIColor.whiteColor()
        searchTextField.font = UIFont(name: Utils().customFontSemiBold, size: 22.0)
        searchTextField.autocorrectionType = UITextAutocorrectionType.No
        //searchTextField.addTarget(self, action: Selector("changedText:"), forControlEvents: UIControlEvents.EditingChanged)
        searchTextField.returnKeyType = UIReturnKeyType.Search
        searchTextField.keyboardAppearance = UIKeyboardAppearance.Light
        searchTopBarView.addSubview(searchTextField)
        
       
        
        
        
        var leftViewSearch:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: searchTextField.frame.size.height))
        var labelStart:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: leftViewSearch.frame.width, height: leftViewSearch.frame.height))
        labelStart.font = UIFont(name: Utils().customFontSemiBold, size: 24)
        labelStart.textColor = UIColor.whiteColor()
        labelStart.text = "@"
        leftViewSearch.addSubview(labelStart)
        searchTextField.leftView = leftViewSearch
        searchTextField.leftViewMode = UITextFieldViewMode.Always
      
        
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
        labelUnlock.text = LocalizedString("TAP TO UNLOCK FRIENDS")
        unlockContactsBar!.addSubview(labelUnlock)
        
        
        typeFriendsSelectorView.frame = CGRect(x: 0, y: 80, width: self.view.frame.width, height: 50)
        
        self.tableView.separatorStyle = .None
        
        //Select Category to print
        
        //FIND TAB
        var gestureFindSelection:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("findSelection:"))
        let findSelectorView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.typeFriendsSelectorView.frame.width/3, height: self.typeFriendsSelectorView.frame.height))
        findSelectorView.backgroundColor = UIColor.whiteColor()
        findSelectorView.addGestureRecognizer(gestureFindSelection)
        typeFriendsSelectorView.addSubview(findSelectorView)
        
        findSelectorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: findSelectorView.frame.width, height: findSelectorView.frame.height))
        findSelectorLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 18)
        findSelectorLabel!.textColor = Utils().primaryColor
        findSelectorLabel!.text = "FIND"
        findSelectorLabel!.textAlignment = NSTextAlignment.Center
        findSelectorView.addSubview(findSelectorLabel!)
        
        //FRIEND TAB
        var gestureFriendsSelection:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("friendsSelection:"))
        let friendsSelectorView:UIView = UIView(frame: CGRect(x: self.typeFriendsSelectorView.frame.width/3, y: 0, width: self.typeFriendsSelectorView.frame.width/3, height: self.typeFriendsSelectorView.frame.height))
        friendsSelectorView.backgroundColor = UIColor.whiteColor()
        friendsSelectorView.addGestureRecognizer(gestureFriendsSelection)
        typeFriendsSelectorView.addSubview(friendsSelectorView)
        
        friendsSelectorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: friendsSelectorView.frame.width, height: friendsSelectorView.frame.height/2 + 10))
        friendsSelectorLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 20)
        friendsSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
        let nbFriendsFormat = String(format: NSLocalizedString("%d FRIENDS", comment : "%d FRIENDS"), getNumberOfFriends())
        friendsSelectorLabel!.text = "\(getNumberOfFriends())"
        friendsSelectorLabel!.textAlignment = NSTextAlignment.Center
        friendsSelectorLabel!.adjustsFontSizeToFitWidth = true
        friendsSelectorView.addSubview(friendsSelectorLabel!)
        
        friendsSelectorLabelBottom = UILabel(frame: CGRect(x: 0, y: friendsSelectorView.frame.height/2, width: friendsSelectorView.frame.width, height: friendsSelectorView.frame.height/2))
        friendsSelectorLabelBottom.font = UIFont(name: Utils().customFontSemiBold, size: 12)
        friendsSelectorLabelBottom.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
        friendsSelectorLabelBottom.text = LocalizedString("YOU FOLLOW")
        friendsSelectorLabelBottom.textAlignment = NSTextAlignment.Center
        friendsSelectorLabelBottom.adjustsFontSizeToFitWidth = true
        friendsSelectorView.addSubview(friendsSelectorLabelBottom)
        
        //RECIPIENTS TAB
        var gestureRecipientsSelection:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("recipientsSelection:"))
        let recipientsSelectorView:UIView = UIView(frame: CGRect(x: self.typeFriendsSelectorView.frame.width/3 * 2, y: 0, width: self.typeFriendsSelectorView.frame.width/3, height: self.typeFriendsSelectorView.frame.height))
        recipientsSelectorView.backgroundColor = UIColor.whiteColor()
        recipientsSelectorView.addGestureRecognizer(gestureRecipientsSelection)
        typeFriendsSelectorView.addSubview(recipientsSelectorView)
        
        recipientsSelectorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: recipientsSelectorView.frame.width, height: recipientsSelectorView.frame.height/2 + 10))
        recipientsSelectorLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 20)
        recipientsSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
        recipientsSelectorLabel!.text = "\(getNumberOfRecipients())"
        recipientsSelectorLabel!.textAlignment = NSTextAlignment.Center
        recipientsSelectorLabel!.adjustsFontSizeToFitWidth = true
        recipientsSelectorView.addSubview(recipientsSelectorLabel!)
        
        recipientsSelectorLabelBottom = UILabel(frame: CGRect(x: 0, y: recipientsSelectorView.frame.height/2, width: recipientsSelectorView.frame.width, height: recipientsSelectorView.frame.height/2))
        recipientsSelectorLabelBottom.font = UIFont(name: Utils().customFontSemiBold, size: 12)
        recipientsSelectorLabelBottom.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
        recipientsSelectorLabelBottom.text = LocalizedString("FOLLOW YOU")
        recipientsSelectorLabelBottom.textAlignment = NSTextAlignment.Center
        recipientsSelectorLabelBottom.adjustsFontSizeToFitWidth = true
        recipientsSelectorView.addSubview(recipientsSelectorLabelBottom)
        
        //INDICATOR SELECTION
        indicatorView = UIView(frame: CGRect(x: 0, y: typeFriendsSelectorView!.frame.height - 2, width: typeFriendsSelectorView!.frame.width/3, height: 2))
        indicatorView!.backgroundColor = Utils().secondColor
        typeFriendsSelectorView!.addSubview(indicatorView!)
        
        
        //Shadow for bottom button
        var stretchShadowImage:UIImage = UIImage(named: "shadow_top")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        let shadowImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: typeFriendsSelectorView.frame.origin.y + typeFriendsSelectorView.frame.size.height , width: UIScreen.mainScreen().bounds.width, height: 4))
        shadowImageView.image = stretchShadowImage
        self.view.addSubview(shadowImageView)
        
        //SEARCH LAYER//
        searchLayer = UIView(frame: CGRect(x: 0, y: searchTopBarView.frame.origin.y + searchTopBarView.frame.height, width: self.view.frame.width, height: self.view.frame.height - (searchTopBarView.frame.origin.y + searchTopBarView.frame.height)))
        searchLayer.backgroundColor = UIColor.clearColor()
        searchLayer.alpha = 0.0
        self.view.addSubview(searchLayer)
        
        //White Background search Layer
        backgroundSearchLayer = UIView(frame: CGRect(x: 0, y: 0, width: searchLayer.frame.width, height: searchLayer.frame.height))
        backgroundSearchLayer.backgroundColor = UIColor.whiteColor()
        backgroundSearchLayer.alpha = 0.85
        searchLayer.addSubview(backgroundSearchLayer)
        
        //Table view search layer
        searchTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: searchLayer.frame.height))
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        searchTableView.registerClass(SearchUserTableViewCell.self, forCellReuseIdentifier: "SearchCell")
        searchTableView.registerClass(PikiUserTableViewCell.self, forCellReuseIdentifier: "PikiUserCell")
        searchTableView.hidden = true
        searchLayer.addSubview(searchTableView)
        
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
        getRecipients()
        
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        Utils().updateUser()
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
        if tableView == searchTableView{
            return 1
        }
        else{
            if printMode == 0 {
                var nbSection:Int = 2
                
                if contactsWithUserInfos.count > 0{
                    nbSection++
                }
                
                if self.lookingForFriendsOnPeekee{
                    nbSection++
                }
                
                
                return nbSection
            }
            else{
                return 2
            }
        }
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView{
            return 1
        }
        else{
            if printMode == 0 {
                if section == 0{
                    return 1
                    
                }
                else if section == 1{
                    if contactsWithUserInfos.count > 0{
                        return contactsWithUserInfos.count
                    }
                    else if self.lookingForFriendsOnPeekee{
                        return 0
                    }
                    else{
                        return sortedContactsPhone.count
                    }
                }
                else{
                    return sortedContactsPhone.count
                }
            }
            else if printMode == 1{
                if section == 0{
                    return 1
                }
                else{
                    return friends.count
                }
                
            }
            else{
                if section == 0{
                    return 1
                }
                else{
                    return recipients.count
                }
            }
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == searchTableView{
            
            if self.usernameUserFound == nil{
                var searchCell:SearchUserTableViewCell = tableView.dequeueReusableCellWithIdentifier("SearchCell") as! SearchUserTableViewCell
                searchCell.selectionStyle = UITableViewCellSelectionStyle.None
                
                if usernameInSearch != nil{
                    searchCell.loadItemLoading(usernameInSearch!, isSearching: self.isSearchingUser)
                }
                else{
                    searchCell.loadItemLoading("", isSearching: self.isSearchingUser)
                }
                
                
                return searchCell
            }
            else{
                var cell:PikiUserTableViewCell = tableView.dequeueReusableCellWithIdentifier("PikiUserCell") as! PikiUserTableViewCell
//                cell.selectionStyle = UITableViewCellSelectionStyle.None
                
                cell.loadItem(self.usernameUserFound!, searchController: self)
                
                
                return cell
            }
            
        }
        else{
            if printMode == 0{
                if indexPath.section == 0{
                    var cell:UITableViewCell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 61))
                    cell.backgroundColor = UIColor(red: 237/255, green: 246/255, blue: 254/255, alpha: 1.0)
                    
                    var certifiedLabel:UILabel = UILabel(frame: CGRect(x: 40, y: 0, width: self.view.frame.width - 80, height: 61))
                    certifiedLabel.font = UIFont(name: Utils().customFontSemiBold, size: 16)
                    certifiedLabel.textColor = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 1.0)
                    certifiedLabel.textAlignment = NSTextAlignment.Center
                    certifiedLabel.adjustsFontSizeToFitWidth = true
                    certifiedLabel.text = LocalizedString("TAP TO VIEW POPULAR ACCOUNTS")
                    cell.addSubview(certifiedLabel)
                    
                    var certifiedIcon:UIImageView = UIImageView(frame: CGRect(x: self.view.frame.width - 45, y: 0, width: 30, height: 61))
                    certifiedIcon.contentMode = UIViewContentMode.Center
                    certifiedIcon.image = UIImage(named: "certified_badge")
                    cell.addSubview(certifiedIcon)
                    
                    var certifiedImages:UIImageView = UIImageView(frame: CGRect(x: 0, y: 13, width: 67, height: 48))
                    certifiedImages.contentMode = UIViewContentMode.Center
                    certifiedImages.image = UIImage(named: "certified_images")
                    cell.addSubview(certifiedImages)
                    
                    
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    
                    return cell
                }
                else if indexPath.section == 1{
                    if contactsWithUserInfos.count > 0{
                        var cellContact:ContactPhoneTableViewCell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as! ContactPhoneTableViewCell
                        
                        var contactUserInfo = contactsWithUserInfos[indexPath.row]
                        
                        
                        
                        cellContact.loadUserContact(contactUserInfo, searchController: self)
//                        cellContact.selectionStyle = UITableViewCellSelectionStyle.None
                        return cellContact
                    }
                    else{
                        var cellContact:ContactPhoneTableViewCell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as! ContactPhoneTableViewCell
                        
                        cellContact.userInfos = nil
                        cellContact.loadContact(sortedContactsPhone[indexPath.row], searchController: self)
//                        cellContact.selectionStyle = UITableViewCellSelectionStyle.None
                        return cellContact
                    }
                    
                }
                else{
                    
                    var cellContact:ContactPhoneTableViewCell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as! ContactPhoneTableViewCell
                    
                    cellContact.userInfos = nil
                    cellContact.loadContact(sortedContactsPhone[indexPath.row], searchController: self)
//                    cellContact.selectionStyle = UITableViewCellSelectionStyle.None
                    return cellContact
                }
            }
            else if printMode == 1{
                if indexPath.section == 0{
                    var cell:UITableViewCell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 61))
                    cell.backgroundColor = UIColor(red: 255/255, green: 252/255, blue: 224/255, alpha: 1.0)
                    
                    var certifiedLabel:UILabel = UILabel(frame: CGRect(x: 45, y: 0, width: self.view.frame.width - 60, height: 61))
                    certifiedLabel.font = UIFont(name: Utils().customFontSemiBold, size: 16)
                    certifiedLabel.textColor = UIColor(red: 249/255, green: 168/255, blue: 37/255, alpha: 1.0)
                    certifiedLabel.adjustsFontSizeToFitWidth = true
                    certifiedLabel.text = LocalizedString("You'll receive their pics & vids")
                    cell.addSubview(certifiedLabel)
                    
                    var receiveIcon:UIImageView = UIImageView(frame: CGRect(x: 15, y: 0, width: 20, height: 61))
                    receiveIcon.contentMode = UIViewContentMode.Center
                    receiveIcon.image = UIImage(named: "receivers_icon")
                    cell.addSubview(receiveIcon)
                    
                    var separatorView:UIView = UIView(frame: CGRect(x: 0, y: 60, width: self.view.frame.width, height: 1))
                    separatorView.backgroundColor = UIColor(red: 249/255, green: 168/255, blue: 37/255, alpha: 1.0)
                    cell.addSubview(separatorView)
                    
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    
                    return cell
                }
                else{
                    var cell:PikiUserTableViewCell = tableView.dequeueReusableCellWithIdentifier("PikiUserCell") as! PikiUserTableViewCell
                    cell.loadItem(friends[indexPath.row], searchController: self)
//                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    
                    
                    if indexPath.row == (friends.count - 20){
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
            else{
                if indexPath.section == 0{
                    var cell:UITableViewCell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 61))
                    cell.backgroundColor = UIColor(red: 255/255, green: 252/255, blue: 224/255, alpha: 1.0)
                    
                    var certifiedLabel:UILabel = UILabel(frame: CGRect(x: 45, y: 0, width: self.view.frame.width - 60, height: 61))
                    certifiedLabel.font = UIFont(name: Utils().customFontSemiBold, size: 16)
                    certifiedLabel.textColor = UIColor(red: 249/255, green: 168/255, blue: 37/255, alpha: 1.0)
                    certifiedLabel.adjustsFontSizeToFitWidth = true
                    certifiedLabel.text = LocalizedString("They will see your public pics & vids.")
                    cell.addSubview(certifiedLabel)
                    
                    var receiveIcon:UIImageView = UIImageView(frame: CGRect(x: 15, y: 0, width: 20, height: 61))
                    receiveIcon.contentMode = UIViewContentMode.Center
                    receiveIcon.image = UIImage(named: "sender_icon")
                    cell.addSubview(receiveIcon)
                    
                    var separatorView:UIView = UIView(frame: CGRect(x: 0, y: 60, width: self.view.frame.width, height: 1))
                    separatorView.backgroundColor = UIColor(red: 249/255, green: 168/255, blue: 37/255, alpha: 1.0)
                    cell.addSubview(separatorView)
                    
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    
                    return cell
                }
                else{
                    var cell:PikiUserTableViewCell = tableView.dequeueReusableCellWithIdentifier("PikiUserCell") as! PikiUserTableViewCell
                    cell.loadItem(recipients[indexPath.row], searchController: self)
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    
                    
                    if indexPath.row == (recipients.count - 20){
                        if recipients.count > 0 && !isLoadingMoreRecipients{
                            if recipients.count % 100 == 0{
                                isLoadingMoreRecipients = true
                                getMoreRecipients()
                            }
                        }
                    }
                    
                    return cell
                }
            }
        }
        
        

    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == searchTableView{
            return 0
        }
        else{
            if printMode == 0{
                
                if self.lookingForFriendsOnPeekee{
                    if section == 1{
                        return 64
                    }
                    else if section > 1 {
                        return 32
                    }
                    else{
                        return 0
                    }
                }
                else{
                    if section > 0{
                        return 32
                    }
                    else{
                        return 0
                    }
                    
                }
            }
            else{
                return 0
            }
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
            }
            else if section == 1{
                if contactsWithUserInfos.count > 0{
                    labelHeader.text = NSLocalizedString("FRIENDS ON PLEEK", comment : "FRIENDS ON PLEEK")
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
                    labelHeader.text = NSLocalizedString("FRIENDS NOT YET ON PLEEK", comment : "FRIENDS NOT YET ON PLEEK")
                }
                
            }
            else{

                labelHeader.text = NSLocalizedString("FRIENDS NOT YET ON PLEEK", comment : "FRIENDS NOT YET ON PLEEK")

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
        
        if let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as? ContactPhoneTableViewCell {
            cell.inviteContact(UIButton())
        } else if let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as? PikiUserTableViewCell {
            cell.addUser(UIButton())
        }

        if tableView == searchTableView{
            
        }
        else{
            if printMode == 0 && indexPath.section == 0{
                self.performSegueWithIdentifier("certifiedAccounts", sender: self)
            }
        }
    }
    
    
    /*
    * TextField Delegate
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        
        var finalText:NSString = textField.text as NSString
        finalText = finalText.stringByReplacingCharactersInRange(range, withString: string).lowercaseString
        
        var textLessWhite:String = finalText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString

        self.usernameUserFound = nil
        self.searchTableView.reloadData()
        
        
        if count(textLessWhite) > 2 {
            
            self.isSearchingUser = true
            self.usernameInSearch = textLessWhite
            self.searchTableView.reloadData()
            
            self.searchTableView.hidden = false
            
            //Get user with this exact username
            
            self.searchUserWithUsername(textLessWhite).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                self.isSearchingUser = false
                var finalText:NSString = textField.text as NSString
                var textLessWhiteNow:String = finalText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString
                
                var canChange:Bool = false
                if textLessWhite == textLessWhiteNow{
                    canChange = true
                }
                
                if task.error != nil{
                    self.searchTableView.reloadData()
                }
                else if task.result != nil{
                    if canChange{
                        self.usernameUserFound = task.result as? PFUser
                        self.searchTableView.reloadData()
                    }
                    
                }
                else{
                    if canChange{
                        self.usernameUserFound = nil
                        self.searchTableView.reloadData()
                    }
                }
                
                return nil
            })
            
        }
        else{
            self.searchTableView.hidden = true
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
    
    
    
    @IBAction func changeSelection(sender: AnyObject) {
        tableView.reloadData()
    }
    
    
    //MARK: GET FRIENDS
    
    func addUserInFriendsList(user : PFUser){
        
        var canAdd:Bool = true
        
        for friend in self.friends{
            if friend.objectId == user.objectId{
                canAdd = false
                break
            }
        }
        
        if canAdd{
            self.friends.append(user)
        }
        
    }
    
    func getFriends(){
        
        Utils().getFriends(true).continueWithBlock { (task : BFTask!) -> AnyObject! in
            
            var queryFriends:PFQuery = User.query()!
            queryFriends.whereKey("objectId", containedIn: Utils().getListOfFriendIdFromJoinObjects(task.result as! Array<PFObject>))
            queryFriends.orderByAscending("username")
            queryFriends.cachePolicy = PFCachePolicy.CacheThenNetwork
            queryFriends.limit = 100
            
            queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
                if error != nil {
                    
                }
                else{
                    self.friends = friends as! Array<PFUser>
                    
                    if self.printMode == 1{
                        self.tableView.reloadData()
                    }
                    
                }
            }
            
            return nil

        }
        
        

    }
    
    func getMoreFriends(){
        
        
        Utils().getFriends(true).continueWithBlock { (task : BFTask!) -> AnyObject! in
            
            var queryFriends:PFQuery = User.query()!
            queryFriends.whereKey("objectId", containedIn: Utils().getListOfFriendIdFromJoinObjects(task.result as! Array<PFObject>))
            queryFriends.orderByAscending("username")
            queryFriends.limit = 100
            queryFriends.skip = self.friends.count
            
            queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
                if error != nil {
                    
                }
                else{
                    
                    var indexPathToInsert:Array<NSIndexPath> = Array<NSIndexPath>()
                    
                    for friend in friends as! Array<PFUser>{
                        self.friends.append(friend)
                        indexPathToInsert.append(NSIndexPath(forRow: self.friends.count - 1, inSection: 1))
                    }
                    
                    if self.printMode == 1{
                        self.tableView.insertRowsAtIndexPaths(indexPathToInsert, withRowAnimation: UITableViewRowAnimation.Fade)
                    }
                    
                    self.isLoadingMore = false
                    
                }
            }
            
            return nil
            
        }
        
    }

    
    func checkContactsOnPiki(){
        
        
        dispatch_async(dispatch_get_global_queue(0, 0), {
            var phoneNumbers:Array<String> = []
            
            let networkInfo = CTTelephonyNetworkInfo()
            let carrier = networkInfo.subscriberCellularProvider
            
            
            
            let phoneUtil:NBPhoneNumberUtil = NBPhoneNumberUtil()
            
            
            
            for contact in self.contactsPhone{
                
                for tel in contact.phones{
                    
                    if (tel as? String) != nil {
                        
                        if count(tel as! String) > 6{
                            var errorPointer:NSError?
                            var number:NBPhoneNumber? = phoneUtil.parse(tel as! String, defaultRegion:self.regionLabel!, error:&errorPointer)
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
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if error != nil {
                        println("Error getting piki Users : \(error!.localizedDescription)")
                        self.lookingForFriendsOnPeekee = false
                        self.tableView.reloadData()
                    }
                    else{
                        self.pikiUsersFromPhoneContacts = pikiUsers as! Array<[String : String]>
                        self.getAllUsersFromContacts()
                    }
                })
                
                
            }
        })
        
        
        
    }
    
    
    /*
    * Utils Functions
    */
    
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
    
    func sortFriends(){
        
        self.friends.sort({ $0.username < $1.username})
        
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
    
    func getUserOfContacts(contact : APContact) -> [String : String]? {
        
        for userInfos in pikiUsersFromPhoneContacts{
            
            for phone in contact.phones{
                
                if getFormattedPhoneNumber(phone as! String) != nil {
                    if userInfos["phoneNumber"] == getFormattedPhoneNumber(phone as! String){
                        return userInfos
                    }
                }
                
            }

        }
        
        return nil
    }
    
    
    func isUserAlreadyAdded(user : PFUser) -> Bool{
        
        for userId in PFUser.currentUser()!["usersFriend"] as! Array<String>{
            if user.objectId == userId{
                
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
            
        case MessageComposeResultSent.value:
            Mixpanel.sharedInstance().track("Send SMS", properties: ["nb_recipients" : controller.recipients.count])
            
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

    func refreshTableView() {
        self.tableView.setContentOffset(CGPointZero, animated: false)
        self.tableView.reloadData()
    }
    
    //MARK: TAB

    func findSelection(gesture : UITapGestureRecognizer){
        
        printMode = 0
        self.refreshTableView()
        
        UIView.animateWithDuration(0.4,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 10.0,
            options: nil,
            animations: { () -> Void in
                self.findSelectorLabel!.textColor = Utils().primaryColor
                self.friendsSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
                self.recipientsSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
                self.friendsSelectorLabelBottom.textColor = Utils().greyNotSelected
                self.recipientsSelectorLabelBottom.textColor = Utils().greyNotSelected
                
                self.indicatorView!.frame = CGRect(x: 0, y: self.indicatorView!.frame.origin.y, width: self.indicatorView!.frame.width, height: self.indicatorView!.frame.height)
            }) { (finished) -> Void in
                println("Show Find")
                
        }
        
    }
    
    
    func friendsSelection(gesture : UITapGestureRecognizer){
        
        printMode = 1
        self.refreshTableView()

        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 10.0,
            options: nil,
            animations: { () -> Void in
                self.friendsSelectorLabel!.textColor = Utils().primaryColor
                self.findSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
                self.recipientsSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
                self.friendsSelectorLabelBottom.textColor = Utils().lightBlue
                self.recipientsSelectorLabelBottom.textColor = Utils().greyNotSelected
                
                
                self.indicatorView!.frame = CGRect(x: self.view.frame.width/3, y: self.indicatorView!.frame.origin.y, width: self.indicatorView!.frame.width, height: self.indicatorView!.frame.height)
        }) { (finished) -> Void in
            println("Show Friends")
            
        }
        
    }
    
    func recipientsSelection(gesture : UITapGestureRecognizer){
        
        printMode = 2
        self.refreshTableView()
        
        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 10.0,
            options: nil,
            animations: { () -> Void in
                self.recipientsSelectorLabel!.textColor = Utils().primaryColor
                self.friendsSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
                self.findSelectorLabel!.textColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
                self.friendsSelectorLabelBottom.textColor = Utils().greyNotSelected
                self.recipientsSelectorLabelBottom.textColor = Utils().lightBlue
                
                self.indicatorView!.frame = CGRect(x: self.view.frame.width/3 * 2, y: self.indicatorView!.frame.origin.y, width: self.indicatorView!.frame.width, height: self.indicatorView!.frame.height)
            }) { (finished) -> Void in
                println("Show Recipients")
                
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
            contactsDenied()
            break
        }
        
        removeUnlockContactsBar()
        
    }
    
    
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
                //self.activity.stopAnimating()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                if (contacts != nil) {
                    //self.memoryStorage().addItems(contacts)
                    //println("Contacts : \(contacts)")
                    self.contactsPhone = contacts as! Array<APContact>
                    self.sortedContactsPhone = contacts as! Array<APContact>
                    
                    if self.printMode == 0{
                        self.lookingForFriendsOnPeekee = true
                        self.tableView.reloadData()
                    }
                    
                    
                    
                    self.checkContactsOnPiki()
                }
                else if (error != nil) {
                    let alert = UIAlertView(title: LocalizedString("Error"), message: error.localizedDescription,
                        delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                    alert.show()
                }
        })
    }
    
    
    func getNumberOfFriends() -> String{
    
        let friendsUser : Array<String> = Utils().getAppDelegate().friendsIdList
        
        return Utils().formatNumber(friendsUser.count)
    
    }
    
    func getNumberOfRecipients() -> String{
        
        if PFUser.currentUser()!["nbRecipients"] != nil{
            return Utils().formatNumber(PFUser.currentUser()!["nbRecipients"] as! Int)
        }
        else{
            return "0"
        }

        
    }
    
    //MARK: GET RECIPIENTS
    
    func getRecipients(){
        
        var queryFriends = PFQuery(className: "Friend")
        queryFriends.whereKey("friend", equalTo: PFUser.currentUser()!)
        queryFriends.limit = 100
        queryFriends.cachePolicy = PFCachePolicy.CacheThenNetwork
        queryFriends.orderByDescending("createdAt")
        queryFriends.includeKey("user")
        
        queryFriends.findObjectsInBackgroundWithBlock { (recipientsObjects, error) -> Void in
            if error != nil {
                
            }
            else{
                self.recipients.removeAll(keepCapacity: false)
                
                for recipientObject in recipientsObjects!{
                    self.recipients.append(recipientObject["user"] as! PFUser)
                }
                
                if self.printMode == 2{
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    func getMoreRecipients(){
        
        var queryFriends = PFQuery(className: "Friend")
        queryFriends.whereKey("friend", equalTo: PFUser.currentUser()!)
        queryFriends.limit = 100
        queryFriends.cachePolicy = PFCachePolicy.NetworkOnly
        queryFriends.orderByDescending("createdAt")
        queryFriends.includeKey("user")
        queryFriends.skip = recipients.count
        
        queryFriends.findObjectsInBackgroundWithBlock { (recipientsObjects, error) -> Void in
            if error != nil {
                
            }
            else{
                
                var indexPathToInsert:Array<NSIndexPath> = Array<NSIndexPath>()
                
                if self.printMode == 2{
                    for recipient in recipientsObjects as! Array<PFObject>{
                        self.recipients.append(recipient["user"] as! PFUser)
                        indexPathToInsert.append(NSIndexPath(forRow: self.recipients.count - 1, inSection: 1))
                    }
                    
                    
                    self.tableView.insertRowsAtIndexPaths(indexPathToInsert, withRowAnimation: UITableViewRowAnimation.Fade)
                }
                
                self.isLoadingMoreRecipients = false
                
            }
        }
        
    }

    
    //MARK : Search Transition
    
    func enterSearch(){
        
        var xFinal:CGFloat = 10
        var xtranslation:CGFloat = self.searchButton.frame.origin.x - xFinal
        
        self.headerLabel.hidden = true
        self.searchButton.enabled = false
        
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                self.quitButton.alpha = 0.0
                self.searchButton.transform = CGAffineTransformMakeTranslation(-xtranslation, 0)
                self.searchLayer.alpha = 1.0
                
        }) { (finished) -> Void in
            self.searchButton.hidden = false
            self.searchTextField.hidden = false
            self.cancelSearchButton!.hidden = false
            self.searchTextField.becomeFirstResponder()
        }
        
    }
    
    func cancelSearch(sender : UIButton){
        
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        searchTextField.hidden = true
        cancelSearchButton!.hidden = true
        self.searchTableView.hidden = true
        self.usernameUserFound = nil
        self.usernameInSearch = nil
        
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.searchButton.transform = CGAffineTransformIdentity
            self.searchLayer.alpha = 0.0
            self.quitButton.alpha = 1.0
            
            }) { (finished) -> Void in
                self.searchButton.enabled = true
                self.headerLabel.hidden = false
        }
        
    }
    
    
    //MARK: SEARCH
    
    //Search a user with this username in my friends
    func searchFriendWithUsername(username : String) -> BFTask{
        
        var completionTask:BFTaskCompletionSource = BFTaskCompletionSource()
        var findInLocalFriends:Bool = false
        
        for friend in friends{
            if  NSString(string: username).containsString(friend.username!){
                findInLocalFriends = true
                completionTask.setResult(friend)
                break
            }
        }
        
        
        //If not in local friends, find it on server
        if !findInLocalFriends{
            Utils().getFriends(true).continueWithBlock { (task : BFTask!) -> AnyObject! in
                
                if task.error != nil{
                    completionTask.setError(task.error)
                }
                else{
                    var queryFriends:PFQuery = User.query()!
                    queryFriends.whereKey("objectId", containedIn: Utils().getListOfFriendIdFromJoinObjects(task.result as! Array<PFObject>))
                    queryFriends.whereKey("username", containsString: username)
                    queryFriends.cachePolicy = PFCachePolicy.CacheThenNetwork
                    queryFriends.limit = 100
                    
                    queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
                        if error != nil {
                            completionTask.setError(error)
                        }
                        else{
                            completionTask.setResult(friends)
                            
                        }
                    }
                }
                
                
                return nil
                
            }
        }
        
        return completionTask.task
    }

    
    //Searcha user with this exact username
    func searchUserWithUsername(username : String) -> BFTask{
        
        var completionTask:BFTaskCompletionSource = BFTaskCompletionSource()
        
        var queryFriends:PFQuery = User.query()!
        queryFriends.whereKey("username", equalTo: username)
        queryFriends.cachePolicy = PFCachePolicy.NetworkOnly
        
        queryFriends.getFirstObjectInBackgroundWithBlock {(user, error) -> Void in
            if error != nil {
                completionTask.setError(error)
            }
            else{
                completionTask.setResult(user)
                
            }
        }
        
        return completionTask.task
    }
    
    
    //MARK: Contacts Denied
    
    func contactsDenied(){
        
        var canOpenSettings:Bool = false
        
        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
        case .OrderedSame, .OrderedDescending:
            var alert = UIAlertController(title: LocalizedString("Error"), message: LocalizedString("To find friends on Pleek you need to grant access to your contacts. Do you want to go to the settings to give access to your contacts?"), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: LocalizedString("No"), style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: LocalizedString("Yes"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                
                self.openSettings()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            break
        case .OrderedAscending:
            UIAlertView(title: LocalizedString("Error"), message: LocalizedString("To find friends on Pleek you need to grant access to your contacts. Please go to Settings > Confidentiality > Contacts and allow it for Pleek"), delegate: nil, cancelButtonTitle: LocalizedString("Ok")).show()
            break
        }
    }
    
    
    func openSettings(){
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
}
