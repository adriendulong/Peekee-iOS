//
//  ChooseReceiversViewController.swift
//  Piki
//
//  Created by Adrien Dulong on 25/11/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation


class RecipientsCell: UITableViewCell {
    
    var testLabel: UILabel?
    var secondLabel:UILabel?
    var selectView:UIView?
    var user:PFUser?
    var chooseControler : ChooseReceiversViewController!
    
    @IBOutlet weak var selectedImageView: UIImageView!
    
    
    func loadItem(#user : PFUser, isSelected:Bool){
        
        if testLabel == nil {
            testLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 60))
            testLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 22.0)
            testLabel!.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            self.addSubview(testLabel!)
            
        }
        
        
        self.backgroundColor = UIColor.whiteColor()
        let username:String = user["username"] as! String
        testLabel!.text = "@\(username)"
        
        
        if isSelected{
            selectedImageView.image = UIImage(named: "select_check_full")
        }
        else{
            selectedImageView.image = UIImage(named: "select_check_empty")
        }
        
        if user["name"] != nil{
            
            if secondLabel == nil{
                secondLabel = UILabel(frame: CGRect(x: 15, y: 30, width: 300, height: 30))
                secondLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 17.0)
                secondLabel!.textColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
                self.addSubview(secondLabel!)
            }
            
            secondLabel!.hidden = false
            testLabel!.frame = CGRect(x: 15, y: 0, width: 300, height: 50)
            
            secondLabel!.text = "@\(user.username!)"
            testLabel!.text = user["name"] as? String
            
        }
        else{
            testLabel!.frame = CGRect(x: 15, y: 0, width: 300, height: 60)
            
            if secondLabel != nil{
                secondLabel!.hidden = true
            }
            
            testLabel!.text = "@\(user.username!)"
            
        }
        
        
        self.user = user
        
        
    }
    
    func setScore(score : Int){
        
        if self.user!["name"] != nil{
            secondLabel!.text = "@\(self.user!.username!) - Score : \(score)"
        }
        else{
            if secondLabel == nil{
                secondLabel = UILabel(frame: CGRect(x: 15, y: 30, width: 300, height: 30))
                secondLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 17.0)
                secondLabel!.textColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
                self.addSubview(secondLabel!)
                
                
                
            }
            secondLabel!.hidden = false
            testLabel!.frame = CGRect(x: 15, y: 0, width: 300, height: 50)
            
            secondLabel!.text = "Score : \(score)"
            testLabel!.text = "@\(self.user!.username!)"
        }
        
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
    
    var topFriendsInfos:Array<[String : AnyObject]> = Array<[String : AnyObject]>()
    var topFriendsInfosAll:Array<[String : AnyObject]> = Array<[String : AnyObject]>()
    
    var supFriendsAdded:Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTopFriends()
        
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
        largeLabelSend!.text = "PUBLIC"
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
        everyOneThirdLabel.text = "PUBLIC"
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
            return topFriendsInfos.count
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
            labelHeader.text = NSLocalizedString("TOP FRIENDS", comment : "TOP FRIENDS")
        }
        else{
            labelHeader.text = NSLocalizedString("FRIENDS", comment : "FRIENDS")
        }
        
        viewHeader.addSubview(labelHeader)
        
        return viewHeader
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:RecipientsCell = tableView.dequeueReusableCellWithIdentifier("RecipientsCell") as! RecipientsCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        var isSelected:Bool = false
        cell.chooseControler = self
        
        
        
        if indexPath.section == 0{
            if isUserSelected(topFriendsInfos[indexPath.row]["user"] as! PFUser, isUserIAdded: true){
                isSelected = true
            }
            
            cell.loadItem(user : topFriendsInfos[indexPath.row]["user"] as! PFUser, isSelected : isSelected)
            cell.setScore(topFriendsInfos[indexPath.row]["score"] as! Int)
        }
        else{
            
            if isUserSelected(userFriends[indexPath.row], isUserIAdded: false){
                isSelected = true
            }
            
            cell.loadItem(user: userFriends[indexPath.row], isSelected : isSelected)
            
            if indexPath.row == (userFriends.count - 1){
                
                if searchTextField!.hidden{
                    if userFriends.count > 0 && !isLoadingMore{
                        var arrayFriendsId:Array<String>? = PFUser.currentUser()!["usersFriend"] as? Array<String>
                        if userFriends.count < (PFUser.currentUser()!["nbFriends"] as! Int){
                            println("Load More")
                            self.isLoadingMore = true
                            getMoreFriends()
                        }
                    }
                }
                
            }
        }
        
        
        
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        var selectCell:RecipientsCell = tableView.cellForRowAtIndexPath(indexPath) as! RecipientsCell
        
        var userToSelect:PFUser?
        if indexPath.section == 0{
            userToSelect = topFriendsInfos[indexPath.row]["user"] as? PFUser
            
            
            if isUserSelected(userToSelect!, isUserIAdded : true ){
                removeUserFromSelected(userToSelect!, isUserIAdded: true)
                (tableView.cellForRowAtIndexPath(indexPath) as! RecipientsCell).deselect()
                animateDeselectFriends()
                //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
            else{
                 addUserToSelected(userToSelect!, isUserIAdded: true)
                (tableView.cellForRowAtIndexPath(indexPath) as! RecipientsCell).select()
                //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                animateSelectFriend()
            }
        }
        else{
            userToSelect = userFriends[indexPath.row]
            
            
            if isUserSelected(userToSelect!, isUserIAdded : false ){
                removeUserFromSelected(userToSelect!, isUserIAdded: false)
                (tableView.cellForRowAtIndexPath(indexPath) as! RecipientsCell).deselect()
                animateDeselectFriends()
                //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
            else{
                addUserToSelected(userToSelect!, isUserIAdded: false)
                (tableView.cellForRowAtIndexPath(indexPath) as! RecipientsCell).select()
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
        println("Users Selected : \(userFriendsSelected.count)")
        
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
        
        Utils().getFriends(true).continueWithBlock { (task : BFTask!) -> AnyObject! in
            
            var queryFriends:PFQuery = PFUser.query()!
            queryFriends.whereKey("objectId", containedIn: Utils().getListOfFriendIdFromJoinObjects(task.result as! Array<PFObject>))
            queryFriends.orderByAscending("username")
            queryFriends.cachePolicy = PFCachePolicy.CacheThenNetwork
            queryFriends.limit = 50
            
            queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
                if error != nil {
                    
                }
                else{
                    
                    self.userFriends = friends as! Array<PFUser>
                    self.userFriendsAll = friends as! Array<PFUser>
                    self.tableView.reloadData()
                }
            }
            
            return nil
            
        }
        
        
        
        
        
    }
    
    
    func getMoreFriends(){
        
        Utils().getFriends(true).continueWithBlock { (task : BFTask!) -> AnyObject! in
            
            var queryFriends:PFQuery = PFUser.query()!
            queryFriends.whereKey("objectId", containedIn: Utils().getListOfFriendIdFromJoinObjects(task.result as! Array<PFObject>))
            queryFriends.orderByAscending("username")
            queryFriends.limit = 100
            queryFriends.skip = self.userFriends.count - self.supFriendsAdded
            
            self.supFriendsAdded = 0
            
            queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
                if error != nil {
                    
                }
                else{
                    
                    var indexPathToInsert:Array<NSIndexPath> = Array<NSIndexPath>()
                    
                    
                    //If friends is no yet in the friends we have add him
                    for friend in friends as! Array<PFUser>{
                        var isFriendPresent:Bool = false
                        
                        for user in self.userFriendsAll{
                            if user.objectId == friend.objectId{
                                isFriendPresent = true
                            }
                        }
                        
                        if !isFriendPresent{
                            self.userFriendsAll.append(friend as PFUser)
                            self.userFriends.append(friend as PFUser)
                            indexPathToInsert.append(NSIndexPath(forRow: self.userFriends.count - 1, inSection: 1))
                        }
                        
                        
                    }
                    
                    self.sortUsers()
                    self.tableView.reloadData()
                    //self.tableView.insertRowsAtIndexPaths(indexPathToInsert, withRowAnimation: UITableViewRowAnimation.Fade)
                    
                    self.isLoadingMore = false
                }
            }
            
            return nil
            
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
            self.topFriendsInfos = self.topFriendsInfosAll
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        var finalText:NSString = textField.text as NSString
        finalText = finalText.stringByReplacingCharactersInRange(range, withString: string).lowercaseString
        
        if finalText.length == 0{
            userFriends = userFriendsAll
            topFriendsInfos = topFriendsInfosAll
        }
        else{
            userFriends.removeAll(keepCapacity: false)
            topFriendsInfos.removeAll(keepCapacity: false)
            
            if finalText.length > 2{
                searchFriendOnServer(finalText as String)
            }
            
            for user in userFriendsAll{
                
                var username:NSString = NSString(string: user.username!)
                
                if Utils().containsStringForAll(username as String, insideString: finalText as String){
                    userFriends.append(user)
                }
                else if user["name"] != nil{
                    if Utils().containsStringForAll(user["name"] as! String, insideString: finalText as String){
                        userFriends.append(user)
                    }
                }
                
            }
            
            for friend in topFriendsInfosAll{
                
                var user:PFUser = friend["user"] as! PFUser
                var username:NSString = NSString(string: user.username!)
                
                if Utils().containsStringForAll(username as String, insideString: finalText as String){
                    topFriendsInfos.append(friend)
                }
                else if user["name"] != nil{
                    if Utils().containsStringForAll(user["name"] as! String, insideString: finalText as String){
                        topFriendsInfos.append(friend)
                    }
                }
                
            }
        }
        
        

        tableView.reloadData()
        
        return true
    }
    
    
    func sortUsers(){
        
        self.userFriends.sort({ $0.username < $1.username})
        self.userFriendsAll.sort({ $0.username < $1.username})
        
        
    }
    
    
    func searchFriendOnServer(username : String){
        
        
        Utils().getFriends(true).continueWithBlock { (task : BFTask!) -> AnyObject! in
            
            var queryFriends:PFQuery = PFUser.query()!
            queryFriends.whereKey("objectId", containedIn: Utils().getListOfFriendIdFromJoinObjects(task.result as! Array<PFObject>))
            queryFriends.whereKey("username", containsString: username)
            queryFriends.orderByAscending("username")
            queryFriends.cachePolicy = PFCachePolicy.CacheThenNetwork
            queryFriends.limit = 100
            
            queryFriends.findObjectsInBackgroundWithBlock { (friends, error) -> Void in
                if error != nil {
                    
                }
                else{
                    var finalText:NSString = self.searchTextField!.text as NSString
                    finalText = finalText.lowercaseString
                    if finalText == username{
                        //If friends is no yet in the friends we have add him
                        for friend in friends as! Array<PFUser>{
                            var isFriendPresent:Bool = false
                            
                            for user in self.userFriendsAll{
                                if user.objectId == friend.objectId{
                                    isFriendPresent = true
                                }
                            }
                            
                            if !isFriendPresent{
                                self.supFriendsAdded++
                                self.userFriendsAll.append(friend as PFUser)
                                self.userFriends.append(friend as PFUser)
                            }
                            
                            
                        }
                        
                        self.sortUsers()
                        self.tableView.reloadData()
                    }
                    
                    
                    
                    
                }
            }
            
            return nil
            
        }
        
    }
    
    func largeSend(gesture : UIGestureRecognizer){
 
        
        if userFriendsSelected.count > 0{
            
            var usersToSend:Array<String> = Array<String>()
            
            for user in userFriendsSelected{
                usersToSend.append(user.objectId!)
            }
            
            
            sendPiki(usersToSend, isPublic: false)
            
        }
        else{
            sendPiki([], isPublic : true)
            
        }
    }
    
    
    func everyoneSend(gesture : UIGestureRecognizer){
        
        sendPiki([], isPublic: true)
        
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
        
        if !isPublic{
            
            recipients.append(PFUser.currentUser()!.objectId!)
            newPiki["recipients"] = recipients
        }
        
        
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
            
            pikiACL.setWriteAccess(true, forUser: PFUser.currentUser()!)
            newPiki.ACL = pikiACL
        }
        
        newPiki.saveInBackgroundWithBlock({ (succeeded:Bool, error:NSError?) -> Void in
            
            if error == nil {
                if self.filePreview != nil{
                    Mixpanel.sharedInstance().track("Send Piki", properties: ["media" : "video", "public" : isPublic])
                    FBSDKAppEvents.logEvent("Send Piki", parameters: ["media" : "video", "public" : isPublic])
                }
                else{
                    Mixpanel.sharedInstance().track("Send Piki", properties: ["media" : "photo", "public" : isPublic])
                    FBSDKAppEvents.logEvent("Send Piki", parameters: ["media" : "photo", "public" : isPublic])
                }
                
                
                Mixpanel.sharedInstance().people.increment("Piki Sent", by: 1)
                
                
                if isPublic{
                    PFCloud.callFunctionInBackground("savePiki",
                        withParameters: ["type" : "sendToAll", "pikiId" : newPiki.objectId!],
                        block: { (result, error) -> Void in
                            if error != nil {
                                self.problemSendingPiki(error!)
                                
                            }
                            else{
                                self.successEndPosting()
                            }
                    })
                }
                else{
                    PFCloud.callFunctionInBackground("savePiki",
                        withParameters: ["type" : "private", "recipients" : usersIdToSend, "pikiId" : newPiki.objectId!],
                        block: { (result, error) -> Void in
                            if error != nil {
                                self.problemSendingPiki(error!)
                                
                            }
                            else{
                                self.successEndPosting()
                            }
                    })
                }
                
                
            }
            else{
                self.problemSendingPiki(error!)
            }
        })
        
        
    }

    
    func problemSendingPiki(error : NSError){
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        var alert = UIAlertController(title: NSLocalizedString("Error", comment : "Error"),
            message: NSLocalizedString("We had a problem while sending your Pleek, please try again later", comment : "We had a problem while sending your Pleek, please try again later"), preferredStyle: UIAlertControllerStyle.Alert)
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
    
    
    // MARK: Top Friends
    
    func getTopFriends(){
        
        var listOfTopFriendsId:Array<String> = Array<String>()
        
        var topFriendsQuery:PFQuery = PFQuery(className: "Friend")
        topFriendsQuery.orderByDescending("score")
        topFriendsQuery.limit = 10
        topFriendsQuery.whereKey("user", equalTo: PFUser.currentUser()!)
        topFriendsQuery.includeKey("friend")
        topFriendsQuery.cachePolicy = PFCachePolicy.CacheThenNetwork
        
        topFriendsQuery.findObjectsInBackgroundWithBlock { (topFriends : [AnyObject]?, error : NSError?) -> Void in
            if error != nil{
                println("Error getting the topFriends")
                
            }
            else{
                println("Top Friends : \(topFriends)")
                self.createAndOrderTopFriends(topFriends as! Array<PFObject>)
            }
        }
        
        
    }
    
    
    func createAndOrderTopFriends(friendsObjects:Array<PFObject>){
        
        var topFriendsInfos:Array<[String : AnyObject]> = Array<[String : AnyObject]>()
        
        for friendObject in friendsObjects{
            
            var topFriendInfo:[String:AnyObject] = ["user" : friendObject["friend"]!, "score" : friendObject["score"]!]
            topFriendsInfos.append(topFriendInfo)

            
        }
        
        self.topFriendsInfosAll = topFriendsInfos
        self.topFriendsInfos = topFriendsInfos
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        
        
    }
    
}