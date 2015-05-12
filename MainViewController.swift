//
//  MainViewController.swift
//  Piki
//
//  Created by Adrien Dulong on 20/10/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation
import Social


class MainViewController : UIViewController, UIScrollViewDelegate, PleekControllerProtocol, TakePhotoProtocol, UITableViewDelegate, UITableViewDataSource, InboxCellProtocol, SearchFriendsProtocol, TutoProtocol, UIAlertViewDelegate{
    
    var loadPikisLimit:Int = 20
    
    //Graphic element form the grid view
    var refreshControl:UIRefreshControl = UIRefreshControl()
    
    //Data
    var lastPikis:Array<PFObject> = []
    var allPikisReacts:NSMutableDictionary = NSMutableDictionary()
    
    //Info to pass
    var pikiToPass:PFObject?
    var reactsToPass:Array<PFObject> = Array<PFObject>()
    var needToRefreshReacts:Bool = false

    
    
    //V2 UI/UX
    var inboxButton:UIButton?
    var friendsButton:UIButton?
    var tabIndicatorView:UIView?
    
    
    var popUpUnlockFriends:UIView?
    var popUpLoopNotif:UIView?
    var overlayView:UIView?
    
    var firstUserUnlock:Bool?
    
    var overlayTutoView:UIView?
    
    //HIDE or DELETE Pleek
    var pikiToDelete:PFObject?
    var positionPeekeeToDelete:Int?
    
    var popUpShowTuto:UIView?
    var showTutoFirst:Bool = false
    
    var isLoadingMore:Bool = false
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {

        //See if show Recommend Accounts
        if PFUser.currentUser()!["hasSeenRecommanded"] != nil{
            if !(PFUser.currentUser()!["hasSeenRecommanded"] as! Bool){
                
                self.performSegueWithIdentifier("showRecommended", sender: self)
                
            }
            else if PFUser.currentUser()!["hasSeenFriends"] == nil {
                //self.performSegueWithIdentifier("showFriends", sender: self)
            }
            else if !(PFUser.currentUser()!["hasSeenFriends"] as! Bool){
                self.performSegueWithIdentifier("showFriends", sender: self)
            }
            else{
                //See if show tuto overlay
                if PFUser.currentUser()!["hasShownOverlayMenu"] != nil{
                    
                    if !(PFUser.currentUser()!["hasShownOverlayMenu"] as! Bool){
                        showTutoOverlay()
                        self.showTutoFirst = true
                        askShowTutoVideo()
                    }
                    
                    
                }
                else{
                    showTutoOverlay()
                }
            }
        }
        else{
            self.performSegueWithIdentifier("showRecommended", sender: self)
        }
        
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updatePikis"), name: "reloadPikis", object: nil)
        
        if Utils().iOS7{
            self.tableView.frame = CGRect(x: 0, y: self.tableView.frame.origin.y - 20, width: self.tableView.frame.width, height: self.tableView.frame.height)
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        refreshControl.tintColor = UIColor(red: 63/255, green: 45/255, blue: 50/255, alpha: 1.0)
        refreshControl.addTarget(self, action: Selector("refresh"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

        
        getPikis(true)
        
        self.view.backgroundColor = UIColor.whiteColor()

        
        
        //V2 UI/UX
        let backStatusBar:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 20))
        backStatusBar.backgroundColor = Utils().statusBarColor
        self.view.addSubview(backStatusBar)
        
        //Shadow Top Bar
        var stretchShadowImage:UIImage = UIImage(named: "shadow")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        let shadowTopBar:UIImageView = UIImageView(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 64))
        shadowTopBar.image = stretchShadowImage
        self.view.addSubview(shadowTopBar)
        
        //Top Bar
        let topBarView:UIView = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 60))
        topBarView.backgroundColor = Utils().primaryColor
        self.view.addSubview(topBarView)
    
        
        
        //View top Right friends
        let gestureGoFriends:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("goFriends:"))
        let friendsView:UIView = UIView(frame: CGRect(x: topBarView.frame.width - 85, y: 0, width: 85, height: topBarView.frame.size.height))
        friendsView.backgroundColor = Utils().primaryColorDark
        friendsView.addGestureRecognizer(gestureGoFriends)
        topBarView.addSubview(friendsView)
        
        let friendIcon:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: friendsView.frame.width, height: friendsView.frame.height))
        friendIcon.contentMode  = UIViewContentMode.Center
        friendIcon.image = UIImage(named: "friends_icon")
        friendsView.addSubview(friendIcon)
        
        //Go settings
        let settingsButton:UIButton = UIButton(frame: CGRect(x: friendsView.frame.origin.x - 50, y: 0, width: 40, height: topBarView.frame.height))
        settingsButton.setImage(UIImage(named: "settings_icon"), forState: UIControlState.Normal)
        settingsButton.addTarget(self, action: Selector("goSettings"), forControlEvents: UIControlEvents.TouchUpInside)
        topBarView.addSubview(settingsButton)
        
        
        var tapGestureParrot = UITapGestureRecognizer(target: self, action: Selector("shareTwitter"))
        var tapGestureParrotSimple = UITapGestureRecognizer(target: self, action: Selector("showVideo"))
        tapGestureParrot.numberOfTapsRequired = 2
        tapGestureParrotSimple.requireGestureRecognizerToFail(tapGestureParrot)
        let parrotView:UIView = UIView(frame: CGRect(x: 15, y: 0, width: 90, height: topBarView.frame.height))
        parrotView.backgroundColor = UIColor.clearColor()
        parrotView.addGestureRecognizer(tapGestureParrot)
        parrotView.addGestureRecognizer(tapGestureParrotSimple)
        topBarView.addSubview(parrotView)
        
        let parrotImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 34, height: parrotView.frame.height))
        parrotImageView.contentMode = UIViewContentMode.Center
        parrotImageView.image = UIImage(named: "parrot_menu")
        parrotView.addSubview(parrotImageView)
        
        //var tapGestureParrotLabel = UITapGestureRecognizer(target: self, action: Selector("shareTwitter"))
        let pikiLabel:UILabel = UILabel(frame: CGRect(x: parrotImageView.frame.width + 15, y: 0, width: 80, height: parrotView.frame.height))
        pikiLabel.text = NSLocalizedString("Pleek", comment : "Pleek")
        pikiLabel.textColor = UIColor.whiteColor()
        //pikiLabel.addGestureRecognizer(tapGestureParrotLabel)
        pikiLabel.userInteractionEnabled = false
        pikiLabel.font = UIFont(name: Utils().customGothamBol, size: 20.0)
        parrotView.addSubview(pikiLabel)
        
        
        let newPikiButton:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 80, y: self.view.frame.size.height - 80, width: 70, height: 70))
        newPikiButton.setImage(UIImage(named: "add_piki"), forState: UIControlState.Normal)
        newPikiButton.addTarget(self, action: Selector("takePiki:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(newPikiButton)
        
        
    }

    /*
    * Other
    */
    
    override func prefersStatusBarHidden() -> Bool {
        return false;
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    func addNewUsers(sender : UIButton){
        self.performSegueWithIdentifier("searchUsers", sender: self)
    }
    
    
    /*
    * SERVER FUNCTIONS
    */
    
    func getPikis(withCache: Bool){
        
        //Get the list of friends : to get the pleek from them
        var friendsObjects:Array<PFUser> = Array<PFUser>()
        Utils().getFriends(true).continueWithBlock { (task : BFTask!) -> AnyObject! in
            if task.error == nil{
                friendsObjects = Utils().getListOfUserObjectFromJoinObject(task.result as! Array<PFObject>)
            }
            
            friendsObjects.append(PFUser(withoutDataWithObjectId: PFUser.currentUser()!.objectId))
            
            //Get the pleek of the friends list
            var requestPiki:PFQuery = PFQuery(className: "Piki")
            requestPiki.orderByDescending("lastUpdate")
            requestPiki.includeKey("user")
            requestPiki.whereKey("user", containedIn: friendsObjects)
            requestPiki.whereKey("objectId", notContainedIn: Utils().getHidesPleek())
            
            if withCache{
                requestPiki.cachePolicy = PFCachePolicy.CacheThenNetwork
            }
            else{
                requestPiki.cachePolicy = PFCachePolicy.NetworkElseCache
            }
            
            
            requestPiki.limit = self.loadPikisLimit
            
            requestPiki.findObjectsInBackgroundWithBlock { (pikis : [AnyObject]?, error : NSError?) -> Void in
                if error != nil{
                    println("Error : \(error!.localizedDescription)")
                    
                }
                else{
                    self.lastPikis = pikis as! Array<PFObject>
                    
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    
                }
            }
            
            return nil
        }
    }
    
    
    func getMorePikis(){
        
        var friendsObjects:Array<PFUser> = Array<PFUser>()
        Utils().getFriends(true).continueWithBlock { (task : BFTask!) -> AnyObject! in
            if task.error == nil{
                friendsObjects = Utils().getListOfUserObjectFromJoinObject(task.result as! Array<PFObject>)
            }
            
            //Add my own id to get my own pleek
            friendsObjects.append(PFUser(withoutDataWithObjectId: PFUser.currentUser()!.objectId))
            
            //Get the pleek
            var requestPiki:PFQuery = PFQuery(className: "Piki")
            requestPiki.orderByDescending("lastUpdate")
            requestPiki.includeKey("user")
            requestPiki.whereKey("user", containedIn: friendsObjects)
            requestPiki.whereKey("objectId", notContainedIn: Utils().getHidesPleek())
            requestPiki.limit = self.loadPikisLimit
            requestPiki.skip = self.lastPikis.count

            requestPiki.findObjectsInBackgroundWithBlock { (pikis : [AnyObject]?, error : NSError?) -> Void in
                if error != nil{
                    println("Error getting the last pikis : \(error!.localizedDescription)")
                    
                }
                else{
                    var indexPathToInsert:Array<NSIndexPath> = Array<NSIndexPath>()
                    
                    for piki in pikis!{
                        self.lastPikis.append(piki as! PFObject)
                        indexPathToInsert.append(NSIndexPath(forRow: self.lastPikis.count - 1, inSection: 0))
                        
                    }
                    
                    self.tableView.insertRowsAtIndexPaths(indexPathToInsert, withRowAnimation: UITableViewRowAnimation.Fade)

                    self.isLoadingMore = false
                }
            }
            
            
            return nil
        }
        
        
        
    }
    
    func getPikisWithoutUpdate(){
        
        var friendsObjects:Array<PFUser> = Array<PFUser>()
        Utils().getFriends(true).continueWithBlock { (task : BFTask!) -> AnyObject! in
            if task.error == nil{
                friendsObjects = Utils().getListOfUserObjectFromJoinObject(task.result as! Array<PFObject>)
            }
            
            friendsObjects.append(PFUser(withoutDataWithObjectId: PFUser.currentUser()!.objectId))
            
            //Get the pleek of the friends list
            var requestPiki:PFQuery = PFQuery(className: "Piki")
            requestPiki.orderByDescending("lastUpdate")
            requestPiki.includeKey("user")
            requestPiki.whereKey("user", containedIn: friendsObjects)
            requestPiki.whereKey("objectId", notContainedIn: Utils().getHidesPleek())
            requestPiki.cachePolicy = PFCachePolicy.NetworkOnly
            
            requestPiki.limit = self.loadPikisLimit
            
            requestPiki.findObjectsInBackgroundWithBlock { (pikis : [AnyObject]?, error : NSError?) -> Void in
            }
            
            return nil
        }
    }
    
    
    /*
    * SEGUE
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailPiki"{

            //let navController:UINavigationController = segue.destinationViewController as UINavigationController
            
            var pikiViewController: PleekViewController = segue.destinationViewController as! PleekViewController
            pikiViewController.mainPiki = self.pikiToPass
            pikiViewController.pikiReacts = self.reactsToPass
            
            pikiViewController.delegate = self
        }
        else if segue.identifier == "takePhoto"{
         
            var navController:UINavigationController = segue.destinationViewController as! UINavigationController
            var takePhotoController:TakePhotoViewController = navController.viewControllers[0] as! TakePhotoViewController
            takePhotoController.delegate = self
        }
        else if segue.identifier == "searchUsers"{
            var searchController: SearchFriendsViewController = segue.destinationViewController as! SearchFriendsViewController
            searchController.delegate = self
            
            if firstUserUnlock != nil {
                searchController.firstUserUnlock = firstUserUnlock!
                firstUserUnlock = nil
            }
            
            
            
    }
        else if segue.identifier == "showVideoTuto"{
            var tutController: TutoVideoViewController = segue.destinationViewController as! TutoVideoViewController
            tutController.delegate = self
            
            if showTutoFirst {
                self.showTutoFirst = false
                tutController.firstTimePlay = true
            }
            
        }
        
            
    }
    
    
    
    /*
    * Refresh
    */
    
    func refresh(){
        getPikis(false)
    }
    
    
    
    
    /*
    * PikiController Delegate
    */
    
    func updateReactsForPiki(piki: PFObject, updateAll : Bool) {
        
        
        if updateAll{
            getPikis(false)
        }
        else{
            
            if !Utils().hasEverViewUnlockFriend(){
                unlockFriendsPopUp()
                Utils().viewUnlockFriend()
            }
            
            var position:Int = 0
            var j:Int = 0
            
            for pikiToReload in self.lastPikis{
                if pikiToReload.objectId == piki.objectId{
                 
                    position = j
                    break
                }
                
                j++
            }
            
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: position, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        }
        
        
        
    }
    
    func updatePikis() {
        
        
        getPikis(false)
    }
    
    
    
    
    /*
    * Gesture recognizer
    */
    
    func takePiki(sender : UIButton){
        
        self.pikiToPass = nil
        self.reactsToPass = Array<PFObject>()
        
        self.performSegueWithIdentifier("takePhoto", sender: self)
    }
    
    
    
    /*
    * TakePhotoProtocol
    */
    
    func newPiki(){
       getPikis(false)
        
    }
    
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
    * User Interaction V2 UX
    */
    
    func goFriends(sender : AnyObject){

        self.performSegueWithIdentifier("searchUsers", sender: self)
    }
    
    
    
    /*
    * Table View V2 UX
    */
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width/3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lastPikis.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var pikiCell:inboxTableViewCell = tableView.dequeueReusableCellWithIdentifier("inboxCell") as! inboxTableViewCell
        pikiCell.delegate = self
        pikiCell.selectionStyle = UITableViewCellSelectionStyle.None
        pikiCell.mainContent!.transform = CGAffineTransformIdentity
        
        pikiCell.backTempImagePiki!.hidden = false
        pikiCell.imagePikiPreview!.hidden = true
        pikiCell.peekee = lastPikis[indexPath.item]
        pikiCell.updateDeleteIcon()
        
        pikiCell.videoIcon.hidden = true
        
        if lastPikis[indexPath.item]["smallPiki"] != nil{
            
            (lastPikis[indexPath.item]["smallPiki"] as! PFFile).getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error != nil {
                    
                }
                else{
                    let arrayIndex:Array<NSIndexPath> = tableView.indexPathsForVisibleRows() as! Array<NSIndexPath>
                    if contains(arrayIndex, indexPath){
                        pikiCell.imagePikiPreview!.image = UIImage(data: data!)
                        pikiCell.backTempImagePiki!.hidden = true
                        pikiCell.imagePikiPreview!.hidden = false
                    }
                }
            })
        }
        else if lastPikis[indexPath.item]["photo"] != nil{
            (lastPikis[indexPath.item]["photo"] as! PFFile).getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error != nil {
                    
                }
                else{
                    let arrayIndex:Array<NSIndexPath> = tableView.indexPathsForVisibleRows() as! Array<NSIndexPath>
                    if contains(arrayIndex, indexPath){
                        pikiCell.imagePikiPreview!.image = UIImage(data: data!)
                        pikiCell.backTempImagePiki!.hidden = true
                        pikiCell.imagePikiPreview!.hidden = false
                    }
                }
            })
        }
        else if lastPikis[indexPath.item]["previewImage"] != nil{
            pikiCell.videoIcon.hidden = false
            (lastPikis[indexPath.item]["previewImage"] as! PFFile).getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error != nil {
                    
                }
                else{
                    let arrayIndex:Array<NSIndexPath> = tableView.indexPathsForVisibleRows() as! Array<NSIndexPath>
                    if contains(arrayIndex, indexPath){
                        pikiCell.imagePikiPreview!.image = UIImage(data: data!)
                        pikiCell.backTempImagePiki!.hidden = true
                        pikiCell.imagePikiPreview!.hidden = false
                    }
                }
            })
        }
        
        
        if lastPikis[indexPath.item]["user"] != nil {
            var user:PFUser = lastPikis[indexPath.item]["user"] as! PFUser
            
            if user["name"] != nil{
                pikiCell.usernameLabel!.attributedText = getLabelUsername(user["name"] as! String)
            }
            else{
                pikiCell.usernameLabel!.attributedText = getLabelUsername(user.username!)
            }
            
        }
        else{
            pikiCell.usernameLabel!.text = ""
        }
        
        
        
        pikiCell.moreInfosViewIndicator!.hidden = false
        pikiCell.firstPreviewReact!.hidden = true
        pikiCell.secondPreviewReact!.hidden = true
        pikiCell.thirdPreviewReact!.hidden = true
        
        if self.lastPikis[indexPath.item]["nbReaction"] != nil {
            
            let nbreact:Int = self.lastPikis[indexPath.item]["nbReaction"] as! Int
            
            if nbreact > 2{
                
                if lastPikis[indexPath.item]["react1"] != nil {
                    pikiCell.firstPreviewReact!.hidden = false
                    
                    (lastPikis[indexPath.item]["react1"] as! PFFile).getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error != nil{
                            
                        }
                        else{
                            if let finalData = data{
                                pikiCell.firstPreviewReact!.image = UIImage(data: finalData)
                            }
                            
                        }
                    })
                    
                    
                    //pikiCell.firstPreviewReact!.file = lastPikis[indexPath.item]["react1"] as PFFile
                    //pikiCell.firstPreviewReact!.loadInBackground()
                }
                
                if lastPikis[indexPath.item]["react2"] != nil {
                    pikiCell.secondPreviewReact!.hidden = false
                    
                    (lastPikis[indexPath.item]["react2"] as! PFFile).getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error != nil{
                            
                        }
                        else{
                            if let finalData = data{
                                pikiCell.secondPreviewReact!.image = UIImage(data: finalData)
                            }
                            
                        }
                    })
                    
                    //pikiCell.secondPreviewReact!.file = lastPikis[indexPath.item]["react2"] as PFFile
                    //pikiCell.secondPreviewReact!.loadInBackground()
                }
                
                if lastPikis[indexPath.item]["react3"] != nil {
                    pikiCell.thirdPreviewReact!.hidden = false
                    
                    (lastPikis[indexPath.item]["react3"] as! PFFile).getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error != nil{
                            
                        }
                        else{
                            if let finalData = data{
                                pikiCell.thirdPreviewReact!.image = UIImage(data: finalData)
                            }
                            
                        }
                    })
                    
                    //pikiCell.thirdPreviewReact!.file = lastPikis[indexPath.item]["react3"] as PFFile
                    //pikiCell.thirdPreviewReact!.loadInBackground()
                }
                
                
               
                
                
                pikiCell.moreInfosViewIndicator!.center = CGPoint(x: pikiCell.thirdPreviewReact!.frame.origin.x + pikiCell.thirdPreviewReact!.frame.size.width + 9 + pikiCell.moreInfosViewIndicator!.frame.size.width/2, y: pikiCell.thirdPreviewReact!.center.y)
            }
            else if nbreact > 1{

                
                if lastPikis[indexPath.item]["react1"] != nil {
                    pikiCell.firstPreviewReact!.hidden = false
                    
                    (lastPikis[indexPath.item]["react1"] as! PFFile).getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error != nil{
                            
                        }
                        else{
                            pikiCell.firstPreviewReact!.image = UIImage(data: data!)
                        }
                    })
                    
                    //pikiCell.firstPreviewReact!.file = lastPikis[indexPath.item]["react1"] as PFFile
                    //pikiCell.firstPreviewReact!.loadInBackground()
                }
                
                if lastPikis[indexPath.item]["react2"] != nil {
                    pikiCell.secondPreviewReact!.hidden = false
                    
                    (lastPikis[indexPath.item]["react2"] as! PFFile).getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error != nil{
                            
                        }
                        else{
                            pikiCell.secondPreviewReact!.image = UIImage(data: data!)
                        }
                    })
                    
                    //pikiCell.secondPreviewReact!.file = lastPikis[indexPath.item]["react2"] as PFFile
                    //pikiCell.secondPreviewReact!.loadInBackground()
                }
                
                pikiCell.moreInfosViewIndicator!.center = CGPoint(x: pikiCell.secondPreviewReact!.frame.origin.x + pikiCell.secondPreviewReact!.frame.size.width + 9 + pikiCell.moreInfosViewIndicator!.frame.size.width/2, y: pikiCell.secondPreviewReact!.center.y)
            }
            else if nbreact > 0{
                if lastPikis[indexPath.item]["react1"] != nil {
                    pikiCell.firstPreviewReact!.hidden = false
                    
                    (lastPikis[indexPath.item]["react1"] as! PFFile).getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error != nil{
                            
                        }
                        else{
                            pikiCell.firstPreviewReact!.image = UIImage(data: data!)
                        }
                    })
                    
                    //pikiCell.firstPreviewReact!.file = lastPikis[indexPath.item]["react1"] as PFFile
                    //pikiCell.firstPreviewReact!.loadInBackground()
                }
                
                pikiCell.moreInfosViewIndicator!.center = CGPoint(x: pikiCell.firstPreviewReact!.frame.origin.x + pikiCell.firstPreviewReact!.frame.size.width + 9 + pikiCell.moreInfosViewIndicator!.frame.size.width/2, y: pikiCell.firstPreviewReact!.center.y)
            }
            else{
                pikiCell.firstPreviewReact!.hidden = true
                pikiCell.secondPreviewReact!.hidden = true
                pikiCell.thirdPreviewReact!.hidden = true
                
                pikiCell.moreInfosViewIndicator!.center = CGPoint(x: pikiCell.firstPreviewReact!.frame.origin.x + pikiCell.moreInfosViewIndicator!.frame.size.width/2, y: pikiCell.answersIcon!.center.y)
            }
            
            //var count:AnyObject = self.lastPikis[indexPath.item]["nbReaction"]
            //cell.nbReactsLabel.text =  "\(count)"
        }
        else{
            //cell.nbReactsLabel.text = "0"
            pikiCell.firstPreviewReact!.hidden = true
            pikiCell.secondPreviewReact!.hidden = true
            pikiCell.thirdPreviewReact!.hidden = true
            
            pikiCell.moreInfosViewIndicator!.center = CGPoint(x: pikiCell.firstPreviewReact!.frame.origin.x + pikiCell.moreInfosViewIndicator!.frame.size.width/2, y: pikiCell.answersIcon!.center.y)
        }
        
        if Utils().hasEverViewThisPiki(self.lastPikis[indexPath.item]){
            if Utils().getInfosLastPikiView(self.lastPikis[indexPath.item])["nbReaction"] != nil {
                var nbReactLastTime:Int = Utils().getInfosLastPikiView(self.lastPikis[indexPath.item])["nbReaction"] as! Int
                
                if self.lastPikis[indexPath.item]["nbReaction"] != nil{
                    var dif:Int = self.lastPikis[indexPath.item]["nbReaction"] as! Int - nbReactLastTime
                    var nbInteraction = self.lastPikis[indexPath.item]["nbReaction"] as! Int
                    
                    if dif > 0{
                        
                        if nbInteraction > 3{
                            pikiCell.moreInfosViewIndicator!.hidden = false
                            pikiCell.moreInfosViewIndicator!.backgroundColor = Utils().primaryColor
                            pikiCell.moreInfosLabel!.text = "+ \(nbInteraction - 3)"
                            pikiCell.moreInfosLabel!.textColor = UIColor.whiteColor()
                            
                            if nbInteraction < 100 {
                                pikiCell.moreInfosViewIndicator!.frame = CGRect(x: pikiCell.moreInfosViewIndicator!.frame.origin.x, y: pikiCell.moreInfosViewIndicator!.frame.origin.y, width: 50, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                                pikiCell.moreInfosLabel!.frame = CGRect(x: 0, y: 0, width: pikiCell.moreInfosViewIndicator!.frame.size.width, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                            }
                            else{
                                pikiCell.moreInfosViewIndicator!.frame = CGRect(x: pikiCell.moreInfosViewIndicator!.frame.origin.x, y: pikiCell.moreInfosViewIndicator!.frame.origin.y, width: 70, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                                pikiCell.moreInfosLabel!.frame = CGRect(x: 0, y: 0, width: pikiCell.moreInfosViewIndicator!.frame.size.width, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                            }
                        }
                        else if nbInteraction == 0 {
                            pikiCell.moreInfosViewIndicator!.frame = CGRect(x: pikiCell.moreInfosViewIndicator!.frame.origin.x, y: pikiCell.moreInfosViewIndicator!.frame.origin.y, width: 100, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                            pikiCell.moreInfosViewIndicator!.center = CGPoint(x: pikiCell.answersIcon!.frame.origin.x + pikiCell.moreInfosViewIndicator!.frame.size.width/2, y: pikiCell.answersIcon!.center.y)
                            pikiCell.moreInfosLabel!.frame = CGRect(x: 0, y: 0, width: pikiCell.moreInfosViewIndicator!.frame.size.width, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                            pikiCell.moreInfosViewIndicator!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
                            pikiCell.moreInfosLabel!.text = LocalizedString("REPLY FIRST")
                            pikiCell.moreInfosLabel!.textColor = UIColor.whiteColor()
                        }
                        else{
                            pikiCell.moreInfosViewIndicator!.hidden = true
                        }
                    }
                    else{
                        if nbInteraction > 3{
                            pikiCell.moreInfosViewIndicator!.hidden = false
                            pikiCell.moreInfosViewIndicator!.backgroundColor = UIColor.whiteColor()
                            pikiCell.moreInfosLabel!.text = "+ \(nbInteraction - 3)"
                            pikiCell.moreInfosLabel!.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
                            
                            if nbInteraction < 100 {
                                pikiCell.moreInfosViewIndicator!.frame = CGRect(x: pikiCell.moreInfosViewIndicator!.frame.origin.x, y: pikiCell.moreInfosViewIndicator!.frame.origin.y, width: 50, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                                pikiCell.moreInfosLabel!.frame = CGRect(x: 0, y: 0, width: pikiCell.moreInfosViewIndicator!.frame.size.width, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                            }
                            else{
                                pikiCell.moreInfosViewIndicator!.frame = CGRect(x: pikiCell.moreInfosViewIndicator!.frame.origin.x, y: pikiCell.moreInfosViewIndicator!.frame.origin.y, width: 70, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                                pikiCell.moreInfosLabel!.frame = CGRect(x: 0, y: 0, width: pikiCell.moreInfosViewIndicator!.frame.size.width, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                            }
                        }
                        else if nbInteraction == 0{
                            pikiCell.moreInfosViewIndicator!.frame = CGRect(x: pikiCell.moreInfosViewIndicator!.frame.origin.x, y: pikiCell.moreInfosViewIndicator!.frame.origin.y, width: 100, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                            pikiCell.moreInfosViewIndicator!.center = CGPoint(x: pikiCell.answersIcon!.frame.origin.x + pikiCell.moreInfosViewIndicator!.frame.size.width/2, y: pikiCell.answersIcon!.center.y)
                            pikiCell.moreInfosLabel!.frame = CGRect(x: 0, y: 0, width: pikiCell.moreInfosViewIndicator!.frame.size.width, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                            pikiCell.moreInfosViewIndicator!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
                            pikiCell.moreInfosLabel!.text = LocalizedString("REPLY FIRST")
                            pikiCell.moreInfosLabel!.textColor = UIColor.whiteColor()
                            
                            
                        }
                        else{
                            pikiCell.moreInfosViewIndicator!.hidden = true
                        }
                    }
                    
                }
                else{
                    pikiCell.moreInfosViewIndicator!.frame = CGRect(x: pikiCell.moreInfosViewIndicator!.frame.origin.x, y: pikiCell.moreInfosViewIndicator!.frame.origin.y, width: 100, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                    pikiCell.moreInfosViewIndicator!.center = CGPoint(x: pikiCell.answersIcon!.frame.origin.x + pikiCell.moreInfosViewIndicator!.frame.size.width/2, y: pikiCell.answersIcon!.center.y)
                    pikiCell.moreInfosLabel!.frame = CGRect(x: 0, y: 0, width: pikiCell.moreInfosViewIndicator!.frame.size.width, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                    pikiCell.moreInfosViewIndicator!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
                    pikiCell.moreInfosLabel!.text = LocalizedString("REPLY FIRST")
                    pikiCell.moreInfosLabel!.textColor = UIColor.whiteColor()
                    
                   
                }
            }
            else{
                if self.lastPikis[indexPath.item]["nbReaction"] != nil{
                    var nbInteraction = self.lastPikis[indexPath.item]["nbReaction"] as! Int
                    
                    if nbInteraction > 3{
                        pikiCell.moreInfosViewIndicator!.hidden = false
                        pikiCell.moreInfosViewIndicator!.backgroundColor = Utils().primaryColor
                        pikiCell.moreInfosLabel!.text = "+ \(nbInteraction - 3)"
                        pikiCell.moreInfosLabel!.textColor = UIColor.whiteColor()
                        
                        if nbInteraction < 100 {
                            pikiCell.moreInfosViewIndicator!.frame = CGRect(x: pikiCell.moreInfosViewIndicator!.frame.origin.x, y: pikiCell.moreInfosViewIndicator!.frame.origin.y, width: 50, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                            pikiCell.moreInfosLabel!.frame = CGRect(x: 0, y: 0, width: pikiCell.moreInfosViewIndicator!.frame.size.width, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                        }
                        else{
                            pikiCell.moreInfosViewIndicator!.frame = CGRect(x: pikiCell.moreInfosViewIndicator!.frame.origin.x, y: pikiCell.moreInfosViewIndicator!.frame.origin.y, width: 70, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                            pikiCell.moreInfosLabel!.frame = CGRect(x: 0, y: 0, width: pikiCell.moreInfosViewIndicator!.frame.size.width, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                        }
                    }
                    else if nbInteraction == 0 {
                        pikiCell.moreInfosViewIndicator!.frame = CGRect(x: pikiCell.moreInfosViewIndicator!.frame.origin.x, y: pikiCell.moreInfosViewIndicator!.frame.origin.y, width: 100, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                        pikiCell.moreInfosViewIndicator!.center = CGPoint(x: pikiCell.answersIcon!.frame.origin.x + pikiCell.moreInfosViewIndicator!.frame.size.width/2, y: pikiCell.answersIcon!.center.y)
                        pikiCell.moreInfosLabel!.frame = CGRect(x: 0, y: 0, width: pikiCell.moreInfosViewIndicator!.frame.size.width, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                        pikiCell.moreInfosViewIndicator!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
                        pikiCell.moreInfosLabel!.text = LocalizedString("REPLY FIRST")
                        pikiCell.moreInfosLabel!.textColor = UIColor.whiteColor()
                    }
                    else{
                        pikiCell.moreInfosViewIndicator!.hidden = true
                    }
                }
                else{
                    pikiCell.moreInfosViewIndicator!.frame = CGRect(x: pikiCell.moreInfosViewIndicator!.frame.origin.x, y: pikiCell.moreInfosViewIndicator!.frame.origin.y, width: 100, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                    pikiCell.moreInfosLabel!.frame = CGRect(x: 0, y: 0, width: pikiCell.moreInfosViewIndicator!.frame.size.width, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
                    pikiCell.moreInfosViewIndicator!.center = CGPoint(x: pikiCell.answersIcon!.frame.origin.x + pikiCell.moreInfosViewIndicator!.frame.size.width/2, y: pikiCell.answersIcon!.center.y)
                    pikiCell.moreInfosViewIndicator!.backgroundColor = UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0)
                    pikiCell.moreInfosLabel!.text = LocalizedString("REPLY FIRST")
                    pikiCell.moreInfosLabel!.textColor = UIColor.whiteColor()
                }
                
            }
        }
        else{
            
            pikiCell.moreInfosViewIndicator!.hidden = false
            pikiCell.moreInfosViewIndicator!.backgroundColor = Utils().secondColor
            pikiCell.moreInfosLabel!.text = LocalizedString("NEW")
            pikiCell.moreInfosLabel!.textColor = UIColor.whiteColor()
            
            pikiCell.moreInfosViewIndicator!.frame = CGRect(x: pikiCell.moreInfosViewIndicator!.frame.origin.x, y: pikiCell.moreInfosViewIndicator!.frame.origin.y, width: 50, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
            pikiCell.moreInfosLabel!.frame = CGRect(x: 0, y: 0, width: pikiCell.moreInfosViewIndicator!.frame.size.width, height: pikiCell.moreInfosViewIndicator!.frame.size.height)
            
        }
        
        
        
        //Load more
        if indexPath.row == (lastPikis.count - 5){
            if lastPikis.count > 0 && !isLoadingMore{
                isLoadingMore = true
                getMorePikis()
            }
        }
        
        return pikiCell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.pikiToPass = lastPikis[indexPath.row]
        if allPikisReacts[lastPikis[indexPath.row].objectId!] != nil {
            self.reactsToPass = allPikisReacts[lastPikis[indexPath.row].objectId!] as! Array<PFObject>
        }
        
        
        self.performSegueWithIdentifier("detailPiki", sender: nil)
    }
    
    
    func goToPiki(piki: PFObject){
        self.pikiToPass = piki
        
        self.performSegueWithIdentifier("detailPiki", sender: nil)
    }
    
    
    /*
    * InboxCellProtocol
    */
    
    // MARK: Inbox Cell Protocol
    
    func deletePiki(cell: inboxTableViewCell) {
        
        if Utils().iOS8{
            var alert = UIAlertController(title: LocalizedString("Confirmation"), message: NSLocalizedString("Are you sure you want to delete this Pleek? There is no way to get back then.", comment : "Are you sure you want to delete this Pleek? There is no way to get back then."), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: LocalizedString("No"), style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                self.lastPikis.insert(self.pikiToDelete!, atIndex: self.positionPeekeeToDelete!)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.positionPeekeeToDelete!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            }))
            alert.addAction(UIAlertAction(title: LocalizedString("Yes"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                println("Yes")
                
                //Delete or Hide
                let userPiki:PFUser = self.pikiToDelete!["user"] as! PFUser
                
                //Delete
                if userPiki.objectId == (PFUser.currentUser()! as PFUser).objectId{
                    PFCloud.callFunctionInBackground("hideOrRemovePikiV2",
                        withParameters: ["pikiId" : self.pikiToDelete!.objectId!], block: { (result : AnyObject?, error : NSError?) -> Void in
                            if error != nil {
                                
                                let alert = UIAlertView(title: LocalizedString("Error"), message: LocalizedString("Problem while deleting this Pleek. Please try again later."),
                                    delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                                alert.show()
                                
                                println("Error : \(error!.localizedDescription)")
                                
                                self.lastPikis.insert(self.pikiToDelete!, atIndex: self.positionPeekeeToDelete!)
                                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.positionPeekeeToDelete!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                            }
                            else{
                                
                                self.getPikisWithoutUpdate()
                                
                            }
                    })
                }
                    //Hide
                else{
                    if (self.pikiToDelete!["isPublic"] as! Bool){
                        Utils().hidePleek(self.pikiToDelete!.objectId!)
                        self.getPikisWithoutUpdate()
                    }
                    else{
                        PFCloud.callFunctionInBackground("hideOrRemovePikiV2",
                            withParameters: ["pikiId" : self.pikiToDelete!.objectId!], block: { (result : AnyObject?, error : NSError?) -> Void in
                                if error != nil {
                                    
                                    let alert = UIAlertView(title: LocalizedString("Error"), message: LocalizedString("Problem while deleting this Pleek. Please try again later."),
                                        delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                                    alert.show()
                                    
                                    println("Error : \(error!.localizedDescription)")
                                    
                                    self.lastPikis.insert(self.pikiToDelete!, atIndex: self.positionPeekeeToDelete!)
                                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.positionPeekeeToDelete!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                                }
                                else{
                                    
                                    self.getPikisWithoutUpdate()
                                    
                                }
                        })
                    }
                    
                    
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else{
            var alertView = UIAlertView(title: LocalizedString("Confirmation"),
                message: NSLocalizedString("Are you sure you want to delete this Pleek? There is no way to get back then.", comment : "Are you sure you want to delete this Pleek? There is no way to get back then."),
                delegate: self, cancelButtonTitle: NSLocalizedString("No", comment : "No"),
                otherButtonTitles: NSLocalizedString("Yes", comment : "Yes"))
            
            alertView.tag = 1
            alertView.show()
        }

        
        var indexPath:NSIndexPath = self.tableView.indexPathForCell(cell)!
        
        var piki:PFObject = self.lastPikis[indexPath.row]
        self.pikiToDelete = piki
        self.positionPeekeeToDelete = indexPath.row

        
        self.lastPikis.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        
        
        
    }

    func getInLoopNotif(){
        
        if overlayView == nil {
            let tapGestureLeavePopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUp"))
            overlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            overlayView!.backgroundColor = UIColor.blackColor()
            overlayView!.alpha = 0.0
            overlayView!.addGestureRecognizer(tapGestureLeavePopUp)
            self.view.addSubview(overlayView!)
        }
        
        if popUpLoopNotif == nil {
            
            
            
            popUpLoopNotif = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 346))
            popUpLoopNotif!.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
            popUpLoopNotif!.center = self.view.center
            popUpLoopNotif!.layer.cornerRadius = 5
            popUpLoopNotif!.clipsToBounds = true
            self.view.addSubview(popUpLoopNotif!)
            
            //let header
            let header:UIView = UIView(frame: CGRect(x: 0, y: 0, width: popUpLoopNotif!.frame.width, height: 48))
            header.backgroundColor = Utils().secondColor
            popUpLoopNotif!.addSubview(header)
            
            let labelBigTime:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height))
            labelBigTime.textAlignment = NSTextAlignment.Center
            labelBigTime.font = UIFont(name: Utils().customFontSemiBold, size: 22)
            labelBigTime.textColor = UIColor.whiteColor()
            labelBigTime.text = NSLocalizedString("GET IN THE LOOP", comment : "GET IN THE LOOP")
            labelBigTime.tag = 12
            header.addSubview(labelBigTime)
            
            let dividerHorizontal:UIView = UIView(frame: CGRect(x: 0, y: 287, width: popUpLoopNotif!.frame.width, height: 1))
            dividerHorizontal.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpLoopNotif!.addSubview(dividerHorizontal)
            
            let dividerVertical:UIView = UIView(frame: CGRect(x: popUpLoopNotif!.frame.width/2, y: 287, width: 1, height: popUpLoopNotif!.frame.height - 287))
            dividerVertical.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpLoopNotif!.addSubview(dividerVertical)
            
            let tapGestureQuitPopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUp"))
            let quitImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 287, width: popUpLoopNotif!.frame.width/2, height: popUpLoopNotif!.frame.height - 287))
            quitImageView.contentMode = UIViewContentMode.Center
            quitImageView.userInteractionEnabled = true
            quitImageView.image = UIImage(named: "close_popup_icon")
            quitImageView.addGestureRecognizer(tapGestureQuitPopUp)
            popUpLoopNotif!.addSubview(quitImageView)
            
            let unlockNotifs:UIImageView = UIImageView(frame: CGRect(x: 0, y: 78, width: popUpLoopNotif!.frame.width, height: 60))
            unlockNotifs.contentMode = UIViewContentMode.Center
            unlockNotifs.image = UIImage(named: "notif_popup_icon")
            popUpLoopNotif!.addSubview(unlockNotifs)

            
            let validateAction:UIButton = UIButton(frame: CGRect(x: popUpLoopNotif!.frame.width/2, y: 287, width: popUpLoopNotif!.frame.width/2, height: popUpLoopNotif!.frame.height - 287))
            validateAction.addTarget(self, action: Selector("validateNotifications"), forControlEvents: UIControlEvents.TouchUpInside)
            validateAction.setImage(UIImage(named: "validate_pop_up"), forState: UIControlState.Normal)
            popUpLoopNotif!.addSubview(validateAction)
            
            let labelPopUp:UILabel = UILabel(frame: CGRect(x: 18, y: 167, width: popUpLoopNotif!.frame.width - 36, height: 90))
            labelPopUp.numberOfLines = 3
            labelPopUp.textAlignment = NSTextAlignment.Center
            labelPopUp.adjustsFontSizeToFitWidth = true
            labelPopUp.font = UIFont(name: Utils().customFontNormal, size: 24.0)
            labelPopUp.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            labelPopUp.text = NSLocalizedString("Don't miss the next pictures from your friends 😁", comment : "Don't miss the next pictures from your friends 😁")
            popUpLoopNotif!.addSubview(labelPopUp)
            
            
        }
        
        self.overlayView!.hidden = false
        self.popUpLoopNotif!.transform =  CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: nil,
            animations: { () -> Void in
                self.overlayView!.alpha = 0.5
                self.popUpLoopNotif!.transform = CGAffineTransformIdentity
            }) { (finisehd) -> Void in
                
        }
        
        
    }
    
    
    
    func unlockFriendsPopUp(){
        
        if overlayView == nil {
            let tapGestureLeavePopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUp"))
            overlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            overlayView!.backgroundColor = UIColor.blackColor()
            overlayView!.alpha = 0.0
            overlayView!.addGestureRecognizer(tapGestureLeavePopUp)
            self.view.addSubview(overlayView!)
        }
        
        if popUpUnlockFriends == nil {
            
            
            
            popUpUnlockFriends = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 284))
            popUpUnlockFriends!.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
            popUpUnlockFriends!.center = self.view.center
            popUpUnlockFriends!.layer.cornerRadius = 5
            popUpUnlockFriends!.clipsToBounds = true
            self.view.addSubview(popUpUnlockFriends!)
            
            //let header
            let header:UIView = UIView(frame: CGRect(x: 0, y: 0, width: popUpUnlockFriends!.frame.width, height: 48))
            header.backgroundColor = Utils().secondColor
            popUpUnlockFriends!.addSubview(header)
            
            let labelBigTime:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height))
            labelBigTime.textAlignment = NSTextAlignment.Center
            labelBigTime.font = UIFont(name: Utils().customFontSemiBold, size: 22)
            labelBigTime.textColor = UIColor.whiteColor()
            labelBigTime.text = NSLocalizedString("BIG TIME!", comment : "BIG TIME!")
            labelBigTime.tag = 12
            header.addSubview(labelBigTime)
            
            let dividerHorizontal:UIView = UIView(frame: CGRect(x: 0, y: 226, width: popUpUnlockFriends!.frame.width, height: 1))
            dividerHorizontal.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpUnlockFriends!.addSubview(dividerHorizontal)
            
            let dividerVertical:UIView = UIView(frame: CGRect(x: popUpUnlockFriends!.frame.width/2, y: 226, width: 1, height: popUpUnlockFriends!.frame.height - 226))
            dividerVertical.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpUnlockFriends!.addSubview(dividerVertical)
            
            let tapGestureQuitPopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUp"))
            let quitImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 226, width: popUpUnlockFriends!.frame.width/2, height: popUpUnlockFriends!.frame.height - 226))
            quitImageView.contentMode = UIViewContentMode.Center
            quitImageView.userInteractionEnabled = true
            quitImageView.image = UIImage(named: "close_popup_icon")
            quitImageView.addGestureRecognizer(tapGestureQuitPopUp)
            popUpUnlockFriends!.addSubview(quitImageView)
            
            let unlockFriendsIcon:UIImageView = UIImageView(frame: CGRect(x: 0, y: 78, width: popUpUnlockFriends!.frame.width, height: 34))
            unlockFriendsIcon.contentMode = UIViewContentMode.Center
            unlockFriendsIcon.image = UIImage(named: "unlock_friends_icon")
            popUpUnlockFriends!.addSubview(unlockFriendsIcon)

            
            let validateAction:UIButton = UIButton(frame: CGRect(x: popUpUnlockFriends!.frame.width/2, y: 226, width: popUpUnlockFriends!.frame.width/2, height: popUpUnlockFriends!.frame.height - 226))
            validateAction.addTarget(self, action: Selector("validateUnlockFriends"), forControlEvents: UIControlEvents.TouchUpInside)
            validateAction.setImage(UIImage(named: "validate_pop_up"), forState: UIControlState.Normal)
            popUpUnlockFriends!.addSubview(validateAction)
            
            let labelPopUp:UILabel = UILabel(frame: CGRect(x: 18, y: 136, width: popUpUnlockFriends!.frame.width - 36, height: 61))
            labelPopUp.numberOfLines = 2
            labelPopUp.textAlignment = NSTextAlignment.Center
            labelPopUp.adjustsFontSizeToFitWidth = true
            labelPopUp.font = UIFont(name: Utils().customFontNormal, size: 24.0)
            labelPopUp.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            labelPopUp.text = NSLocalizedString("Let's find your friends on the app! 🙇", comment : "Let's find your friends on the app! 🙇")
            popUpUnlockFriends!.addSubview(labelPopUp)
            
            
        }

        self.overlayView!.hidden = false
        self.popUpUnlockFriends!.transform =  CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: nil,
            animations: { () -> Void in
                self.overlayView!.alpha = 0.5
                self.popUpUnlockFriends!.transform = CGAffineTransformIdentity
            }) { (finisehd) -> Void in
                
        }
        
        
    }
    
    
    func validateNotifications(){
        
        leavePopUp(false)
        //Ask For Notif
        if PFUser.currentUser() != nil{
            //Notifications
            if UIApplication.sharedApplication().respondsToSelector(Selector("registerUserNotificationSettings:")){
                let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert |
                    UIUserNotificationType.Badge |
                    UIUserNotificationType.Sound, categories: nil)
                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                UIApplication.sharedApplication().registerForRemoteNotifications()
            }
            else{
                UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound)
            }
        }
    }
    
    
    func validateUnlockFriends(){
        
        leavePopUp(false)
        self.firstUserUnlock = true
        self.performSegueWithIdentifier("searchUsers", sender: self)
    }
    
    func leavePopUp(){
        leavePopUp(true)
    }
    
    func leavePopUp(showingNextScreen : Bool){
        
        if self.popUpUnlockFriends != nil{
            
            if showingNextScreen {
                self.firstUserUnlock = false
                self.performSegueWithIdentifier("searchUsers", sender: self)
            }
            
            
            UIView.animateWithDuration(0.1,
                animations: { () -> Void in
                    self.overlayView!.alpha = 0
                    if self.popUpUnlockFriends != nil {
                        self.popUpUnlockFriends!.transform = CGAffineTransformMakeScale(0.01, 0.01)
                    }
                    
                    if self.popUpLoopNotif != nil{
                        self.popUpLoopNotif!.transform = CGAffineTransformMakeScale(0.01, 0.01)
                    }
                    
                    
                }) { (finished) -> Void in
                    if self.popUpUnlockFriends != nil {
                        self.popUpUnlockFriends!.transform =  CGAffineTransformMakeScale(0, 0)
                        self.popUpUnlockFriends!.removeFromSuperview()
                        self.popUpUnlockFriends = nil
                    }
                    
                    if self.popUpLoopNotif != nil{
                        self.popUpLoopNotif!.transform =  CGAffineTransformMakeScale(0, 0)
                        self.popUpLoopNotif!.removeFromSuperview()
                        self.popUpLoopNotif = nil
                    }
                    self.overlayView!.removeFromSuperview()
                    self.overlayView = nil
                    
                    
                    
            }
        }
        else{
            UIView.animateWithDuration(0.3,
                animations: { () -> Void in
                    self.overlayView!.alpha = 0
                    if self.popUpUnlockFriends != nil {
                        self.popUpUnlockFriends!.transform = CGAffineTransformMakeScale(0.01, 0.01)
                    }
                    
                    if self.popUpLoopNotif != nil{
                        self.popUpLoopNotif!.transform = CGAffineTransformMakeScale(0.01, 0.01)
                    }
                    
                    
                }) { (finished) -> Void in
                    if self.popUpUnlockFriends != nil {
                        self.popUpUnlockFriends!.transform =  CGAffineTransformMakeScale(0, 0)
                        self.popUpUnlockFriends!.removeFromSuperview()
                        self.popUpUnlockFriends = nil
                    }
                    
                    if self.popUpLoopNotif != nil{
                        self.popUpLoopNotif!.transform =  CGAffineTransformMakeScale(0, 0)
                        self.popUpLoopNotif!.removeFromSuperview()
                        self.popUpLoopNotif = nil
                    }
                    self.overlayView!.removeFromSuperview()
                    self.overlayView = nil
                    
                    
                    
            }
        }
        
        
    }
    
    
    
    // MARK: SearchFriendsProtocol 
    
    func leaveSearchFriends() {
        
        if !Utils().hasEverViewInLoop(){
            getInLoopNotif()
            Utils().viewInLoop()
        }
        
    }
    
    
    // MARK : Overlay 
    
    func showTutoOverlay(){
        
        if overlayTutoView == nil{
            
            overlayTutoView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            overlayTutoView!.backgroundColor = UIColor.clearColor()
            
            let gestureTapLeaveOverlay:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leaveOverlayTuto"))
            overlayTutoView!.addGestureRecognizer(gestureTapLeaveOverlay)
            
            
            let statusOverlay = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
            statusOverlay.backgroundColor = UIColor.blackColor()
            statusOverlay.alpha = 0.7
            overlayTutoView!.addSubview(statusOverlay)
            
            
            
            let topBarOverlay:UIView = UIView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width - 85, height: 60))
            topBarOverlay.backgroundColor = UIColor.blackColor()
            topBarOverlay.alpha = 0.7
            overlayTutoView!.addSubview(topBarOverlay)
            
            
            let firstPeekeeOverlay:UIView = UIView(frame: CGRect(x: 0, y: 80, width: self.view.frame.size.width, height: self.view.frame.size.width/3))
            firstPeekeeOverlay.backgroundColor = UIColor.blackColor()
            firstPeekeeOverlay.alpha = 0.7
            overlayTutoView!.addSubview(firstPeekeeOverlay)
            
            let restOverlay = UIView(frame: CGRect(x: 0, y: 80 + 2 * (self.view.frame.size.width/3), width: self.view.frame.size.width, height: self.view.frame.height - (80 + 2 * (self.view.frame.size.width/3))))
            restOverlay.backgroundColor = UIColor.blackColor()
            restOverlay.alpha = 0.7
            overlayTutoView!.addSubview(restOverlay)
            
            let lineFriends:UIImageView = UIImageView(frame: CGRect(x: self.view.frame.width - 40 - 42, y: 76, width: 42, height: 47))
            lineFriends.image = UIImage(named: "menu_line_friends")
            overlayTutoView!.addSubview(lineFriends)
            
            let linePeekee = UIImageView(frame: CGRect(x: self.view.frame.size.width/6, y: restOverlay.frame.origin.y - 4, width: 47, height: 42))
            linePeekee.image = UIImage(named: "menu_line_peekee")
            overlayTutoView!.addSubview(linePeekee)
            
            let labelTutoFriends = UILabel(frame: CGRect(x: 10, y: 95, width: self.view.frame.width - 40 - 42 - 10 - 30, height: 43))
            labelTutoFriends.numberOfLines = 2
            labelTutoFriends.adjustsFontSizeToFitWidth = true
            labelTutoFriends.font = UIFont(name: Utils().customGothamBol, size: 24.0)
            labelTutoFriends.textColor = UIColor.whiteColor()
            labelTutoFriends.text = NSLocalizedString("Find more friends to get more Pleeks", comment : "Find more friends to get more Pleeks")
            overlayTutoView!.addSubview(labelTutoFriends)
            
            let labelTutoPeekee = UILabel(frame: CGRect(x: linePeekee.frame.origin.x + linePeekee.frame.width + 5, y: linePeekee.frame.origin.y + 30, width: self.view.frame.width - (linePeekee.frame.origin.x + linePeekee.frame.width + 5), height: 22))
            labelTutoPeekee.numberOfLines = 1
            labelTutoPeekee.font = UIFont(name: Utils().customGothamBol, size: 24.0)
            labelTutoPeekee.textColor = UIColor.whiteColor()
            labelTutoPeekee.adjustsFontSizeToFitWidth = true
            labelTutoPeekee.text = NSLocalizedString("This is a PLEEK 🍩", comment : "This is a PLEEK 🍩")
            overlayTutoView!.addSubview(labelTutoPeekee)
            
            let labelSplash = UILabel(frame: CGRect(x: labelTutoFriends.frame.origin.x + labelTutoFriends.frame.width - 10, y: labelTutoFriends.center.y - 10, width: 30, height: 30))
            labelSplash.text = "💥"
            labelSplash.font = UIFont(name: Utils().customGothamBol, size: 30.0)
            overlayTutoView!.addSubview(labelSplash)
            
            self.view.addSubview(overlayTutoView!)
        }
        
        PFUser.currentUser()!["hasShownOverlayMenu"] = true
        PFUser.currentUser()!.saveInBackgroundWithBlock { (finished, error) -> Void in
            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (user, error) -> Void in
                println("UPDATE USER")
            })
        }
        
    }
    
    
    func leaveOverlayTuto(){
        overlayTutoView!.removeFromSuperview()
    }
    
    
    func shareTwitter(){
        var okTwitter :Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
        
        if okTwitter{
            
            Mixpanel.sharedInstance().track("PeekeeIcon")
            
            var composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)

            composer.setInitialText(LocalizedString("Hey @Pleekapp I just clicked on your awesome icon! #itouchedpleek"))
            composer.addURL(NSURL(string: Utils().websiteUrl))
            
            var imageToShare:UIImage? = Utils().getShareUsernameImage()
            
            if imageToShare != nil{
                composer.addImage(imageToShare)
            }
            
            composer.completionHandler = {
                (result:SLComposeViewControllerResult) in
                println("Result : \(result)")
            }
            self.presentViewController(composer, animated: true, completion: nil)
            
        }
        else{
            
        }
    }
    
    
    
    func getLabelUsername(username : String) -> NSMutableAttributedString{
        
        var fromLabel:String = NSLocalizedString("From", comment :"From")
        var totalLabel:String = "\(fromLabel) \(username)"
        
        var mutableString:NSMutableAttributedString = NSMutableAttributedString(string: totalLabel)
        
        mutableString.addAttribute(NSFontAttributeName, value: UIFont(name: Utils().customFontSemiBold, size: 16.0)!, range: NSRange(location: 0,length: count(fromLabel)))
        
        mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 209/255, green: 212/255, blue: 218/255, alpha: 1.0), range: NSRange(location: 0,length: count(fromLabel)))
    
        mutableString.addAttribute(NSFontAttributeName, value: UIFont(name: Utils().customFontSemiBold, size: 24.0)!, range: NSRange(location: count(fromLabel),length: count(totalLabel) - count(fromLabel)))
        
        mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0), range: NSRange(location: count(fromLabel),length: count(totalLabel) - count(fromLabel)))
        
        return mutableString
        
        
    }
    
    
    func setName(){
        if Utils().iOS8{
            var alert = UIAlertController(title: NSLocalizedString("Edit your name", comment : "Edit your name"), message: NSLocalizedString("To help your friend to find you please set your real name.", comment : "To help your friend to find you please set your real name."), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler { (textfield : UITextField!) -> Void in
                textfield.placeholder =  NSLocalizedString("Your real name", comment : "Your real name")
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment : "Cancel"), style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                
                var alertLater = UIAlertController(title: NSLocalizedString("Later", comment : "Later"), message: NSLocalizedString("If you want to change your name anytime later go to the settings from the friends screen.", comment : "If you want to change your name anytime later go to the settings from the friends screen."), preferredStyle: UIAlertControllerStyle.Alert)
                alertLater.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment : "Ok"), style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertLater, animated: true, completion: nil)
                
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment : "Ok"), style: UIAlertActionStyle.Default , handler: { (action) -> Void in
                
                var realName:String = (alert.textFields!.first! as! UITextField).text
                
                if count(realName) > 3 && count(realName) < 30{
                    PFUser.currentUser()!["name"] = realName
                    PFUser.currentUser()!.saveEventually()
                    
                    Mixpanel.sharedInstance().people.set(["Name" : realName])
                    
                    var alertLater = UIAlertController(title: NSLocalizedString("Later", comment : "Later"), message: NSLocalizedString("If you want to change your name anytime later go to the settings from the friends screen.", comment : "If you want to change your name anytime later go to the settings from the friends screen."), preferredStyle: UIAlertControllerStyle.Alert)
                    alertLater.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment : "Ok"), style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alertLater, animated: true, completion: nil)
                }
                else{
                    var alertProblem = UIAlertController(title: NSLocalizedString("Error", comment : "Error"), message: NSLocalizedString("Your real name must have at least 3 characters and can have 30 characters max.", comment : "Your real name must have at least 3 characters and can have 30 characters max."), preferredStyle: UIAlertControllerStyle.Alert)
                    alertProblem.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment : "Ok"), style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                        self.presentViewController(alert, animated: true, completion: nil)
                    }))
                    self.presentViewController(alertProblem, animated: true, completion: nil)
                }
                
                
                
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else{
            var alertView = UIAlertView(title:  LocalizedString("Real Name"),
                message: LocalizedString("To help your friends to find you please set your real name in the settings of the app."),
                delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment : "Cancel"),
                otherButtonTitles: NSLocalizedString("Ok", comment : "Ok"))
            alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
            alertView.tag = 2
            alertView.show()
        }
        
        
    }
    
    
    func testMuteAll(){
        
        PFCloud.callFunctionInBackground("callMuteAll", withParameters: ["test" : "rien"])
    }
    
    
    //MARK : Tuto Video
    
    func showVideo(){
        self.performSegueWithIdentifier("showVideoTuto", sender: self)
    }
    
    func askShowTutoVideo(){
        
        if overlayView == nil {
            let tapGestureLeavePopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUpTuto"))
            overlayView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            overlayView!.backgroundColor = UIColor.blackColor()
            overlayView!.alpha = 0.0
            overlayView!.addGestureRecognizer(tapGestureLeavePopUp)
            self.view.addSubview(overlayView!)
        }
        
        if popUpShowTuto == nil {
            
            
            
            popUpShowTuto = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 284))
            popUpShowTuto!.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
            popUpShowTuto!.center = self.view.center
            popUpShowTuto!.layer.cornerRadius = 5
            popUpShowTuto!.clipsToBounds = true
            self.view.addSubview(popUpShowTuto!)
            
            //let header
            let header:UIView = UIView(frame: CGRect(x: 0, y: 0, width: popUpShowTuto!.frame.width, height: 48))
            header.backgroundColor = Utils().secondColor
            popUpShowTuto!.addSubview(header)
            
            let labelBigTime:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height))
            labelBigTime.textAlignment = NSTextAlignment.Center
            labelBigTime.font = UIFont(name: Utils().customFontSemiBold, size: 22)
            labelBigTime.textColor = UIColor.whiteColor()
            labelBigTime.text = NSLocalizedString("SOME HELP?!", comment : "SOME HELP?!")
            labelBigTime.tag = 12
            header.addSubview(labelBigTime)
            
            let dividerHorizontal:UIView = UIView(frame: CGRect(x: 0, y: 226, width: popUpShowTuto!.frame.width, height: 1))
            dividerHorizontal.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpShowTuto!.addSubview(dividerHorizontal)
            
            let dividerVertical:UIView = UIView(frame: CGRect(x: popUpShowTuto!.frame.width/2, y: 226, width: 1, height: popUpShowTuto!.frame.height - 226))
            dividerVertical.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            popUpShowTuto!.addSubview(dividerVertical)
            
            let tapGestureQuitPopUp:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("leavePopUpTuto"))
            let quitImageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 226, width: popUpShowTuto!.frame.width/2, height: popUpShowTuto!.frame.height - 226))
            quitImageView.contentMode = UIViewContentMode.Center
            quitImageView.userInteractionEnabled = true
            quitImageView.image = UIImage(named: "close_popup_icon")
            quitImageView.addGestureRecognizer(tapGestureQuitPopUp)
            popUpShowTuto!.addSubview(quitImageView)
            
            let unlockFriendsIcon:UIImageView = UIImageView(frame: CGRect(x: 0, y: 78, width: popUpShowTuto!.frame.width, height: 34))
            unlockFriendsIcon.contentMode = UIViewContentMode.Center
            unlockFriendsIcon.image = UIImage(named: "unlock_friends_icon")
            //popUpShowTuto!.addSubview(unlockFriendsIcon)
            
            let tvLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 78, width: popUpShowTuto!.frame.width, height: 40))
            tvLabel.font = UIFont(name: Utils().customFontSemiBold, size: 45)
            tvLabel.textAlignment = NSTextAlignment.Center
            tvLabel.text = "📺"
            popUpShowTuto!.addSubview(tvLabel)
            
            
            let validateAction:UIButton = UIButton(frame: CGRect(x: popUpShowTuto!.frame.width/2, y: 226, width: popUpShowTuto!.frame.width/2, height: popUpShowTuto!.frame.height - 226))
            validateAction.addTarget(self, action: Selector("leavePopUpTutoShowVideo"), forControlEvents: UIControlEvents.TouchUpInside)
            validateAction.setImage(UIImage(named: "validate_pop_up"), forState: UIControlState.Normal)
            popUpShowTuto!.addSubview(validateAction)
            
            let labelPopUp:UILabel = UILabel(frame: CGRect(x: 18, y: 136, width: popUpShowTuto!.frame.width - 36, height: 70))
            labelPopUp.numberOfLines = 3
            labelPopUp.textAlignment = NSTextAlignment.Center
            labelPopUp.adjustsFontSizeToFitWidth = true
            labelPopUp.font = UIFont(name: Utils().customFontNormal, size: 24.0)
            labelPopUp.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
            labelPopUp.text = NSLocalizedString("Do you want to watch a simple video to understand Pleek?", comment : "Look at this 10 sec' video to get the PLEEK concept?")
            popUpShowTuto!.addSubview(labelPopUp)
            
            
        }
        
        self.overlayView!.hidden = false
        self.popUpShowTuto!.transform =  CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: nil,
            animations: { () -> Void in
                self.overlayView!.alpha = 0.5
                self.popUpShowTuto!.transform = CGAffineTransformIdentity
            }) { (finisehd) -> Void in
                
        }
        
        
    }
    
    func leavePopUpTuto(){
        
        UIView.animateWithDuration(0.1,
            animations: { () -> Void in
                self.overlayView!.alpha = 0
                self.popUpShowTuto!.transform = CGAffineTransformMakeScale(0.01, 0.01)
                
                
            }) { (finished) -> Void in
                self.popUpShowTuto!.transform =  CGAffineTransformMakeScale(0, 0)
                self.popUpShowTuto!.removeFromSuperview()
                self.popUpShowTuto = nil
                self.overlayView!.removeFromSuperview()
                self.overlayView = nil
                
                
                let alert = UIAlertView(title: NSLocalizedString("Find Tuto", comment : "Find Tuto"), message: NSLocalizedString("If you're lost anytime, just touch the parrot on the top left of the screen!", comment : "If you're lost anytime, just touch the parrot on the top left of the screen!"),
                    delegate: nil, cancelButtonTitle: LocalizedString("Ok"))
                alert.show()
        }
        
    }
    
    
    func leavePopUpTutoShowVideo(){
        
        UIView.animateWithDuration(0.1,
            animations: { () -> Void in
                self.overlayView!.alpha = 0
                self.popUpShowTuto!.transform = CGAffineTransformMakeScale(0.01, 0.01)
                
                
            }) { (finished) -> Void in
                self.popUpShowTuto!.transform =  CGAffineTransformMakeScale(0, 0)
                self.popUpShowTuto!.removeFromSuperview()
                self.popUpShowTuto = nil
                self.overlayView!.removeFromSuperview()
                self.overlayView = nil
                
                self.showVideo()
                
        }
        
    }
    
    func letsSayWhereVideo(){
        self.showTutoFirst = false
        let alert = UIAlertView(title: NSLocalizedString("Find Tuto", comment : "Find Tuto"), message: NSLocalizedString("If you're lost anytime, just touch the parrot on the top left of the screen!", comment : "If you're lost anytime, just touch the parrot on the top left of the screen!"),
            delegate: nil, cancelButtonTitle: LocalizedString("Ok"))
        alert.show()
    }
    
    
    
    // MARK : Alert View Delegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 1{
            
            // No Remove
            if buttonIndex == 0{
                self.lastPikis.insert(self.pikiToDelete!, atIndex: self.positionPeekeeToDelete!)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.positionPeekeeToDelete!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            //REmove
            else{
                //Delete or Hide
                let userPiki:PFUser = self.pikiToDelete!["user"] as! PFUser
                
                //Delete
                if userPiki.objectId! == PFUser.currentUser()!.objectId!{
                    PFCloud.callFunctionInBackground("hideOrRemovePikiV2",
                        withParameters: ["pikiId" : self.pikiToDelete!.objectId!], block: { (result, error) -> Void in
                            if error != nil {
                                
                                let alert = UIAlertView(title: LocalizedString("Error"), message: LocalizedString("Problem while deleting this Pleek. Please try again later."),
                                    delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                                alert.show()
                                
                                println("Error : \(error!.localizedDescription)")
                                
                                self.lastPikis.insert(self.pikiToDelete!, atIndex: self.positionPeekeeToDelete!)
                                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.positionPeekeeToDelete!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                            }
                            else{
                                
                                self.getPikisWithoutUpdate()
                                
                            }
                    })
                }
                    //Hide
                else{
                    if (self.pikiToDelete!["isPublic"] as! Bool){
                        Utils().hidePleek(self.pikiToDelete!.objectId!)
                        self.getPikisWithoutUpdate()
                    }
                    else{
                        PFCloud.callFunctionInBackground("hideOrRemovePikiV2",
                            withParameters: ["pikiId" : self.pikiToDelete!.objectId!], block: { (result : AnyObject?, error : NSError?) -> Void in
                                if error != nil {
                                    
                                    let alert = UIAlertView(title: LocalizedString("Error"), message: LocalizedString("Problem while deleting this Pleek. Please try again later."),
                                        delegate: nil, cancelButtonTitle: LocalizedString("OK"))
                                    alert.show()
                                    
                                    println("Error : \(error!.localizedDescription)")
                                    
                                    self.lastPikis.insert(self.pikiToDelete!, atIndex: self.positionPeekeeToDelete!)
                                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.positionPeekeeToDelete!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                                }
                                else{
                                    
                                    self.getPikisWithoutUpdate()
                                    
                                }
                        })
                    }
                }
            }
            
            println("Button Index : \(buttonIndex)")
            
        }
        else if alertView.tag == 2{
            if buttonIndex == 1{
                var textField:UITextField = alertView.textFieldAtIndex(0)!
                println("Text field text : \(textField.text)")
                
                var realName:String = textField.text
                
                if count(realName) > 3 && count(realName) < 30{
                    PFUser.currentUser()!["name"] = realName
                    PFUser.currentUser()!.saveEventually()
                    
                    Mixpanel.sharedInstance().people.set(["Name" : realName])
                    
                    var alertView = UIAlertView(title:  NSLocalizedString("Later", comment : "Later"), message: NSLocalizedString("If you want to change your name anytime later go to the settings from the friends screen.", comment : "If you want to change your name anytime later go to the settings from the friends screen."), delegate: nil, cancelButtonTitle:  NSLocalizedString("Ok", comment : "Ok"))
                    
                    alertView.show()
                }
                else{
                    
                    var alertView = UIAlertView(title:  NSLocalizedString("Error", comment : "Error"),
                        message: NSLocalizedString("Your real name must have at least 3 characters and can have 30 characters max.", comment : "Your real name must have at least 3 characters and can have 30 characters max."),
                        delegate: self, cancelButtonTitle:NSLocalizedString("Ok", comment : "Ok"))
                    alertView.tag = 3
                    alertView.show()
                    
                }
            }
            else{
                
                var alertView = UIAlertView(title:  NSLocalizedString("Later", comment : "Later"), message: NSLocalizedString("If you want to change your name anytime later go to the settings from the friends screen.", comment : "If you want to change your name anytime later go to the settings from the friends screen."), delegate: nil, cancelButtonTitle:  NSLocalizedString("Ok", comment : "Ok"))
                
                alertView.show()
            }
            
        }
        
        else if alertView.tag == 3{
            var alertView = UIAlertView(title:  "Real Name",
                message: "To help your friends to find you please set your real name in the settings of the app.",
                delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment : "Cancel"),
                otherButtonTitles: NSLocalizedString("Ok", comment : "Ok"))
            alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
            alertView.tag = 2
            alertView.show()
        }
    }
    
    
    func goSettings(){
        self.performSegueWithIdentifier("goSettings", sender: self)
    }
    
    
}