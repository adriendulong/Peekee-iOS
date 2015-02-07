//
//  ChooseReceiversViewController.swift
//  Piki
//
//  Created by Adrien Dulong on 25/11/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation


class RecipientsCell: UITableViewCell {
    
    @IBOutlet weak var testLabel: UILabel!
    var selectView:UIView?
    var user:PFUser?
    var chooseControler : ChooseReceiversViewController!
    
    @IBOutlet weak var selectedImageView: UIImageView!
    
    
    func loadItem(#user : PFUser, isSelected:Bool){
        testLabel.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
        testLabel.font = UIFont(name: Utils().customFontSemiBold, size: 20.0)
        
        self.backgroundColor = UIColor.whiteColor()
        let username:String = user["username"] as String
        testLabel.text = "@\(username)"
        
        
        if isSelected{
            selectedImageView.image = UIImage(named: "select_check_full")
        }
        else{
            selectedImageView.image = UIImage(named: "select_check_empty")
        }
        
        
        self.user = user
        
        
    }
    
    func select(){
        
        chooseControler.updateSelectedLabel()
        selectedImageView.image = UIImage(named: "select_check_full")
        UIView.animateWithDuration(0.1,
            delay: 0,
            options:nil,
            animations: { () -> Void in
                self.selectedImageView.transform = CGAffineTransformMakeScale(1.6, 1.6)
        }) { (finished) -> Void in
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.selectedImageView.transform = CGAffineTransformIdentity
            })
            
        }
    }
    
    func deselect(){
        chooseControler.updateSelectedLabel()
        selectedImageView.image = UIImage(named: "select_check_empty")
    }
    
}

class ChooseReceiversViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var quitButton: UIButton!
    
    var addSomeoneLabel:UILabel?
    
    var allFriendsAdded:Bool = false
    var allFriendsWhoAdded:Bool = false
    
    var precedentOffsetScrollView:CGFloat?
    var selectedIndexPaths:[NSIndexPath] = []
    
    var sendMainButton:UIButton?
    
    var usersWhoAddedMe:Array<PFUser> = []
    var usersWhoAddedMeSelected:Array<PFUser> = []
    var usersIAlreadyAdded:Array<PFUser> = []
    var usersIAlreadyAddedSelected:Array<PFUser> = []
    var userFriends:Array<PFUser> = []
    var userFriendsAll:Array<PFUser> = []
    var userFriendsSelected:Array<PFUser> = []
    
    
    //Photo infos
    var filePiki:PFFile?
    var filePreview:PFFile?
    var textOnPiki:String?
    
    var finalPhoto:UIImage?
    
    //V2 UX
    var topBarViewNew:UIView?
    var topBarRightCornerView:UIView?
    var backButton:UIButton?
    var sendToLabel:UILabel?
    var searchTextField:UITextField?
    var topRightCornerImage:UIImageView?
    
    var searchButton:UIButton?
    
    var largeSendView:UIView?
    var largeLabelSend:UILabel?
    var oneThirdViewSend:UIView?
    var nbSelectedLabel : UILabel?
    var isLoadingMore:Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadContacts"), name: "updateContacts", object: nil)
        
        tableView.backgroundColor = UIColor.whiteColor()
        
        var gestureLargeSend:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("largeSend:"))
        largeSendView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 55, width: self.view.frame.width, height: 55))
        largeSendView!.backgroundColor = Utils().secondColor
        largeSendView!.addGestureRecognizer(gestureLargeSend)
        self.view.addSubview(largeSendView!)

        let sendIconImageView:UIImageView = UIImageView(frame: CGRect(x: self.view.frame.width - 30 - 26, y: 17, width: 26, height: 22))
        sendIconImageView.image = UIImage(named: "send_icon")
        largeSendView!.addSubview(sendIconImageView)
        
        largeLabelSend = UILabel(frame: CGRect(x: 0, y: 0, width: largeSendView!.frame.width, height: largeSendView!.frame.height))
        largeLabelSend!.font = UIFont(name: Utils().customFontSemiBold, size: 18)
        largeLabelSend!.textColor = UIColor.whiteColor()
        largeLabelSend!.textAlignment = NSTextAlignment.Center
        largeLabelSend!.text = NSLocalizedString("SEND TO EVERYONE", comment :"SEND TO EVERYONE")
        largeSendView!.addSubview(largeLabelSend!)
        
        nbSelectedLabel = UILabel(frame: CGRect(x: largeSendView!.frame.width/3 + 25, y: 0, width: largeSendView!.frame.width/3 * 2 - 40, height: largeSendView!.frame.height))
        nbSelectedLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 16)
        nbSelectedLabel!.textColor = UIColor.whiteColor()
        nbSelectedLabel!.text = "10 000 SELECTED"
        nbSelectedLabel!.alpha = 0.0
        largeSendView!.addSubview(nbSelectedLabel!)
        
        var gestureEveryone:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("everyoneSend:"))
        oneThirdViewSend = UIView(frame: CGRect(x: 0, y: 0, width: largeSendView!.frame.width/3, height: largeSendView!.frame.height))
        oneThirdViewSend!.backgroundColor = UIColor(red: 233/255, green: 54/255, blue: 115/255, alpha: 1.0)
        oneThirdViewSend!.transform = CGAffineTransformMakeTranslation(-largeSendView!.frame.width/3, 0)
        oneThirdViewSend!.addGestureRecognizer(gestureEveryone)
        largeSendView!.addSubview(oneThirdViewSend!)
        
        let everyOneThirdLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: oneThirdViewSend!.frame.width, height: oneThirdViewSend!.frame.height))
        everyOneThirdLabel.font = UIFont(name: Utils().customFontSemiBold, size: 16)
        everyOneThirdLabel.textColor = UIColor.whiteColor()
        everyOneThirdLabel.adjustsFontSizeToFitWidth = true
        everyOneThirdLabel.text = NSLocalizedString("EVERYONE", comment : "EVERYONE")
        everyOneThirdLabel.textAlignment = NSTextAlignment.Center
        oneThirdViewSend!.addSubview(everyOneThirdLabel)
        
        /*sendMainButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 50, width: self.view.frame.size.width, height: 50))
        sendMainButton!.setTitle("Send", forState: UIControlState.Normal)
        sendMainButton!.backgroundColor = Utils().cyanColor
        sendMainButton!.setTitleColor(Utils().darkColor, forState: UIControlState.Normal)
        sendMainButton!.titleLabel!.font = UIFont(name: Utils().customFont, size: 26.0)
        sendMainButton!.addTarget(self, action: Selector("sendPiki:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(sendMainButton!)*/
        
        getFriends()
        
        
        //UX V2
        let statusBarView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        statusBarView.backgroundColor = Utils().statusBarColor
        self.view.addSubview(statusBarView)
        
        topBarViewNew = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 60))
        topBarViewNew!.backgroundColor = Utils().primaryColor
        self.view.addSubview(topBarViewNew!)
        
        var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("addFriends:"))
        topBarRightCornerView = UIView(frame: CGRect(x: self.view.frame.width - 80, y: 0, width: 80, height: topBarViewNew!.frame.size.height))
        topBarRightCornerView!.backgroundColor = Utils().primaryColorDark
        topBarRightCornerView!.addGestureRecognizer(tapGesture)
        topBarViewNew!.addSubview(topBarRightCornerView!)
        
        topRightCornerImage = UIImageView(frame: CGRect(x: topBarRightCornerView!.frame.width/2 - 10 , y: topBarRightCornerView!.frame.height/2 - 10, width: 19, height: 19))
        topRightCornerImage!.image = UIImage(named: "add_friends")
        topBarRightCornerView!.addSubview(topRightCornerImage!)
        
        backButton = UIButton(frame: CGRect(x: 0, y: 0, width: topBarViewNew!.frame.height, height: topBarViewNew!.frame.height))
        backButton!.setBackgroundImage(finalPhoto!, forState: UIControlState.Normal)
        backButton!.setImage(UIImage(named: "previous_icon"), forState: UIControlState.Normal)
        backButton!.addTarget(self, action: Selector("backToPhoto:"), forControlEvents: UIControlEvents.TouchUpInside)
        topBarViewNew!.addSubview(backButton!)
        
        var tapGestureOpenSearchLabel = UITapGestureRecognizer(target: self, action: Selector("openSearch"))
        sendToLabel = UILabel(frame: CGRect(x: topBarViewNew!.frame.height + 10, y: 0, width: 150, height: topBarViewNew!.frame.height))
        sendToLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 18)
        sendToLabel!.text = NSLocalizedString("Send to...", comment : "Send to...")
        sendToLabel!.textColor = UIColor.whiteColor()
        sendToLabel!.userInteractionEnabled = true
        sendToLabel!.addGestureRecognizer(tapGestureOpenSearchLabel)
        topBarViewNew!.addSubview(sendToLabel!)
        
        searchTextField = UITextField(frame: CGRect(x: 2 * topBarViewNew!.frame.height, y: 0, width: topBarViewNew!.frame.width - 3 * topBarViewNew!.frame.height, height: topBarViewNew!.frame.height))
        searchTextField!.backgroundColor = UIColor.clearColor()
        searchTextField!.font = UIFont(name: Utils().customFontSemiBold, size: 16)
        searchTextField!.textColor = UIColor.whiteColor()
        searchTextField!.placeholder = NSLocalizedString("Search", comment : "Search")
        searchTextField!.delegate = self
        searchTextField!.hidden = true
        topBarViewNew!.addSubview(searchTextField!)
        
        searchButton = UIButton(frame: CGRect(x: topBarViewNew!.frame.width - topBarViewNew!.frame.width/4 - topBarViewNew!.frame.height, y: 0, width: topBarViewNew!.frame.height, height: topBarViewNew!.frame.height))
        searchButton!.setImage(UIImage(named: "search_icon"), forState: UIControlState.Normal)
        searchButton!.addTarget(self, action: Selector("openSearch"), forControlEvents: UIControlEvents.TouchUpInside)
        topBarViewNew!.addSubview(searchButton!)

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        /*UIView.animateWithDuration(2, animations: { () -> Void in
            self.topBarView.frame = CGRect(x: 0, y: 0, width: self.topBarView.frame.size.width, height: 20)
            self.addPeopleTopBarView.frame = CGRect(x: 0, y: 20, width: self.addPeopleTopBarView.frame.size.width, height: self.addPeopleTopBarView.frame.size.height)
        })*/
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    /*
    * TABLE VIEW
    */
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 61
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return usersWhoAddedMe.count
        }
        else{
            return userFriends.count
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var viewHeader:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 32))
        viewHeader.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
        
        var labelHeader:UILabel = UILabel(frame: CGRect(x: 15, y: 0, width: viewHeader.frame.size.width - 30, height: viewHeader.frame.size.height))
        labelHeader.font = UIFont(name: Utils().customFontSemiBold, size: 18.0)
        labelHeader.textColor = UIColor.whiteColor()
        
        
        var gesture:UITapGestureRecognizer?
        if section == 0{
            labelHeader.text = NSLocalizedString("RECENT", comment : "RECENT")
            gesture = UITapGestureRecognizer(target: self, action: Selector("selectAllFriendsAdded"))
        }
        else{
            labelHeader.text = NSLocalizedString("FRIENDS", comment : "FRIENDS")
            gesture = UITapGestureRecognizer(target: self, action: Selector("selectAllFriendsWhoAdded"))
        }
        
        viewHeader.addSubview(labelHeader)
        
        return viewHeader
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:RecipientsCell = tableView.dequeueReusableCellWithIdentifier("RecipientsCell") as RecipientsCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        var isSelected:Bool = false
        cell.chooseControler = self
        
        
        
        if indexPath.section == 0{
            if isUserSelected(usersWhoAddedMe[indexPath.row], isUserIAdded: true){
                isSelected = true
            }
            
            cell.loadItem(user : usersWhoAddedMe[indexPath.row], isSelected : isSelected)
        }
        else{
            
            if isUserSelected(userFriends[indexPath.row], isUserIAdded: false){
                isSelected = true
            }
            
            cell.loadItem(user: userFriends[indexPath.row], isSelected : isSelected)
        }
        
        
        if indexPath.row == (userFriends.count - 10){
            
            if searchTextField!.hidden{
                if userFriends.count > 0 && !isLoadingMore{
                    if userFriends.count % 100 == 0{
                        println("Load More")
                        self.isLoadingMore = true
                        getMoreFriends()
                    }
                }
            }
            
            
            
            
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        var selectCell:RecipientsCell = tableView.cellForRowAtIndexPath(indexPath) as RecipientsCell
        
        var userToSelect:PFUser?
        if indexPath.section == 0{
            userToSelect = usersWhoAddedMe[indexPath.row]
            
            
            if isUserSelected(userToSelect!, isUserIAdded : true ){
                removeUserFromSelected(userToSelect!, isUserIAdded: true)
                (tableView.cellForRowAtIndexPath(indexPath) as RecipientsCell).deselect()
                animateDeselectFriends()
                //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
            else{
                 addUserToSelected(userToSelect!, isUserIAdded: true)
                (tableView.cellForRowAtIndexPath(indexPath) as RecipientsCell).select()
                //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                animateSelectFriend()
            }
        }
        else{
            userToSelect = userFriends[indexPath.row]
            
            
            if isUserSelected(userToSelect!, isUserIAdded : false ){
                removeUserFromSelected(userToSelect!, isUserIAdded: false)
                (tableView.cellForRowAtIndexPath(indexPath) as RecipientsCell).deselect()
                animateDeselectFriends()
                //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
            else{
                addUserToSelected(userToSelect!, isUserIAdded: false)
                (tableView.cellForRowAtIndexPath(indexPath) as RecipientsCell).select()
                //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                animateSelectFriend()
            }
        }
        
        tableView.reloadData()
        
        
        
    }
    
    

    func animateSelectFriend(){
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.largeLabelSend!.alpha = 0.0
            self.nbSelectedLabel!.alpha = 1.0
            self.oneThirdViewSend!.transform = CGAffineTransformIdentity
        })
    }
    
    func animateDeselectFriends(){
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            if self.userFriendsSelected.count < 1{
                self.nbSelectedLabel!.alpha = 0.0
                self.largeLabelSend!.alpha = 1.0
                self.oneThirdViewSend!.transform = CGAffineTransformMakeTranslation(-self.largeSendView!.frame.width/3, 0)
            }
            
        })
    }
    
    
    func isUserSelected(user : PFUser, isUserIAdded : Bool) -> Bool{
        
        for userToVerify in userFriendsSelected{
            if userToVerify.objectId == user.objectId{
                return true
            }
        }
        
        
        return false
        
    }
    
    func removeUserFromSelected(user : PFUser, isUserIAdded : Bool){
        
        var increment:Int = 0
        var positionToRemove:Int?
        
        for userToVerify in userFriendsSelected {
            if userToVerify.objectId == user.objectId{
                positionToRemove = increment
            }
            increment++
        }
        
        if positionToRemove != nil {
            userFriendsSelected.removeAtIndex(positionToRemove!)
        }
    }
    
    func removeIndexPathFromSelected(indexPath : NSIndexPath){
        var positionOfSelected:Int?
        var increment:Int = 0
        for index in selectedIndexPaths{
            if index.row == indexPath.row && index.section == indexPath.section{
                positionOfSelected = increment
                break
            }
            increment++
        }
        
        if positionOfSelected != nil{
            selectedIndexPaths.removeAtIndex(positionOfSelected!)
        }
        
    }
    
    func addUserToSelected(user : PFUser, isUserIAdded : Bool){
        
        userFriendsSelected.append(user)
        
    }
    
    func addIndexPathToSelected(indexPath : NSIndexPath){
        selectedIndexPaths.append(indexPath)
    }
    
    
    /*  
    * Actions Functions
    */
    
    @IBAction func quitRecipients(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    /*
    * SERVER Functions
    */
    
    
    //GET ALL USER FRIENDS
    func getFriends(){
        
        var arrayFriendsId:Array<String>? = PFUser.currentUser()["usersFriend"] as? Array<String>
        
        
        if arrayFriendsId != nil {
            var queryFriends:PFQuery = PFUser.query()
            queryFriends.whereKey("objectId", containedIn: arrayFriendsId!)
            queryFriends.orderByAscending("username")
            queryFriends.cachePolicy = kPFCachePolicyCacheThenNetwork
            queryFriends.limit = 100
            
            queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
                if error != nil {
                    
                }
                else{
                    
                    self.userFriends = friends as Array<PFUser>
                    self.userFriendsAll = friends as Array<PFUser>
                    //self.sortUsers()
                    self.tableView.reloadData()
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
            queryFriends.skip = userFriends.count
            
            queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
                if error != nil {
                    
                }
                else{
                    
                    var indexPathToInsert:Array<NSIndexPath> = Array<NSIndexPath>()
                    
                    for friend in friends as Array<PFUser>{
                        self.userFriends.append(friend)
                        self.userFriendsAll.append(friend)
                        indexPathToInsert.append(NSIndexPath(forRow: self.userFriends.count - 1, inSection: 1))
                    }
                    
                    self.tableView.insertRowsAtIndexPaths(indexPathToInsert, withRowAnimation: UITableViewRowAnimation.Fade)
                    
                    self.isLoadingMore = false
                }
            }
        }
        
    }
    
    
    
    
    func  backToPhoto(button : UIButton){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func addFriends(button : UIButton){
        
        if searchTextField!.hidden{
            self.performSegueWithIdentifier("addFriends", sender: self)
        }
        else{
            self.searchTextField!.hidden = true
            self.searchTextField!.resignFirstResponder()
            self.searchTextField!.text = ""
            
            self.userFriends = self.userFriendsAll
            self.tableView.reloadData()
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self.topBarRightCornerView!.backgroundColor = Utils().primaryColorDark
                self.topRightCornerImage!.transform = CGAffineTransformIdentity
                self.sendToLabel!.alpha = 1
                
                self.searchButton!.frame = CGRect(x: self.topBarViewNew!.frame.width - self.topBarViewNew!.frame.width/4 - self.topBarViewNew!.frame.height, y: 0, width: self.searchButton!.frame.width, height: self.searchButton!.frame.height)
                }) { (finished) -> Void in
                    
                    
            }
        }
        
    }
    
    func openSearch(){
        
        if searchTextField!.hidden{
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.sendToLabel!.alpha = 0
                self.topBarRightCornerView!.backgroundColor = Utils().primaryColor
                self.topRightCornerImage!.transform = CGAffineTransformMakeRotation(CGFloat((45.0)/180.0 * M_PI))
                
                
                self.searchButton!.frame = CGRect(x: self.topBarViewNew!.frame.height, y: 0, width: self.searchButton!.frame.width, height: self.searchButton!.frame.height)
                }) { (finished) -> Void in
                    self.searchTextField!.hidden = false
                    self.searchTextField!.becomeFirstResponder()
            }
            
        }
        
    }
    
    
    /*
    * Text Field Delegate
    */
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        
        
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        var finalText:NSString = textField.text as NSString
        finalText = finalText.stringByReplacingCharactersInRange(range, withString: string).lowercaseString
        
        userFriends.removeAll(keepCapacity: false)
        
        for user in userFriendsAll{
            
            var username:NSString = NSString(string: user.username)
            
            if Utils().containsStringForAll(username, insideString: finalText){
                userFriends.append(user)
            }
            
        }

        tableView.reloadData()
        
        return true
    }
    
    
    func sortUsers(){
        
        self.userFriends.sort({ $0.username < $1.username})
        self.userFriendsAll.sort({ $0.username < $1.username})
        
        
    }
    
    func largeSend(gesture : UIGestureRecognizer){
        
        if userFriendsSelected.count > 0{
            
            var usersToSend:Array<String> = Array<String>()
            
            for user in userFriendsSelected{
                usersToSend.append(user.objectId)
            }
            
            
            sendPiki(recipientsWithoutBlockedOnes(usersToSend), isPublic: false)
            
        }
        else{
            if PFUser.currentUser()["usersFriend"] != nil{
                sendPiki(recipientsWithoutBlockedOnes(PFUser.currentUser()["usersFriend"] as Array<String>), isPublic: true)
            }
            
        }
    }
    
    
    func everyoneSend(gesture : UIGestureRecognizer){
        
        if PFUser.currentUser()["usersFriend"] != nil{
            sendPiki(recipientsWithoutBlockedOnes(PFUser.currentUser()["usersFriend"] as Array<String>), isPublic: true)
        }
        
    }
    
    func recipientsWithoutBlockedOnes(usersId : Array<String>) -> Array<String>{
        
        var usersToSend:Array<String> = Array<String>()
        let usersBlocked:Array<String>? = PFUser.currentUser()["usersWhoMutedMe"] as Array<String>?
        
        
        if usersBlocked != nil{
            for userId in usersId{
                
                if  !contains(usersBlocked!, userId){
                    usersToSend.append(userId)
                }
                
            }
        }
        else{
            usersToSend = usersId
        }
        
        return usersToSend

    }
    
    
    func sendPiki(usersIdToSend : Array<String>, isPublic : Bool){
        
        
        
        //Loader
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        var newPiki:PFObject = PFObject(className: "Piki")
        
        if self.filePreview != nil{
            newPiki["previewImage"] = self.filePreview!
            newPiki["video"] = filePiki!
        }
        else{
            newPiki["photo"] = filePiki!
        }
        
        
        var recipients:Array<String> = usersIdToSend
        recipients.append(PFUser.currentUser().objectId)
        newPiki["recipients"] = recipients
        newPiki["isPublic"] = isPublic
        
        
        //Set the user who took the PIki and set rights
        if PFUser.currentUser() != nil{
            newPiki["user"] = PFUser.currentUser()
            var pikiACL:PFACL = PFACL()
            
            if isPublic{
                pikiACL.setPublicReadAccess(true)
            }
            else{
                for recipient in recipients{
                    pikiACL.setReadAccess(true, forUserId: recipient)
                }
            }
            
            pikiACL.setWriteAccess(true, forUser: PFUser.currentUser())
            newPiki.ACL = pikiACL
        }
        
        newPiki.saveInBackgroundWithBlock({ (succeeded:Bool, error:NSError!) -> Void in
            
            if error == nil {
                if self.filePreview != nil{
                    Mixpanel.sharedInstance().track("Send Piki", properties: ["media" : "video", "public" : isPublic])
                    FBAppEvents.logEvent("Send Piki", parameters: ["media" : "video", "public" : isPublic])
                }
                else{
                    Mixpanel.sharedInstance().track("Send Piki", properties: ["media" : "photo", "public" : isPublic])
                    FBAppEvents.logEvent("Send Piki", parameters: ["media" : "photo", "public" : isPublic])
                }
                
                
                Mixpanel.sharedInstance().people.increment("Piki Sent", by: 1)
                
                
                if isPublic{
                    PFCloud.callFunctionInBackground("savePiki",
                        withParameters: ["type" : "sendToAll", "pikiId" : newPiki.objectId],
                        block: { (result, error) -> Void in
                            if error != nil {
                                self.problemSendingPiki(error)
                                
                            }
                            else{
                                self.successEndPosting()
                            }
                    })
                }
                else{
                    PFCloud.callFunctionInBackground("savePiki",
                        withParameters: ["type" : "private", "recipients" : usersIdToSend, "pikiId" : newPiki.objectId],
                        block: { (result, error) -> Void in
                            if error != nil {
                                self.problemSendingPiki(error)
                                
                            }
                            else{
                                self.successEndPosting()
                            }
                    })
                }
                
                //self.delegate!.newPiki()
                
            }
            else{
                self.problemSendingPiki(error)
            }
        })
        
        
    }

    
    func problemSendingPiki(error : NSError){
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        var alert = UIAlertController(title: NSLocalizedString("Error", comment : "Error"),
            message: NSLocalizedString("We had a problem while sending your Peekee, please try again later", comment : "We had a problem while sending your Peekee, please try again later"), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func updateSelectedLabel(){
        let nbFriendsFormat = String(format: NSLocalizedString("%d SELECTED", comment : "%d SELECTED"), userFriendsSelected.count)
        nbSelectedLabel!.text = nbFriendsFormat
        
    }
    
    func successEndPosting(){
        NSNotificationCenter.defaultCenter().postNotificationName("reloadPikis", object: nil)
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reloadContacts(){
        getFriends()
    }
    
}