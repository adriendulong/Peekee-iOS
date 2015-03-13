//
//  ListRecipientsViewController.swift
//  Piki
//
//  Created by Adrien Dulong on 19/12/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import AVFoundation


class RecipientsPikiCell: UITableViewCell {

    var actionButton:UIButton?
    var loadIndicator:UIActivityIndicatorView?
    
    @IBOutlet weak var nameLabel: UILabel!
    var user:PFUser?
    
    func loadItem(#user : PFUser){
        self.user = user
       
        if actionButton == nil {
            actionButton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 50, y: 0, width: 45, height: 60))
            //actionButton!.addTarget(self, action: Selector("inviteContact:"), forControlEvents: UIControlEvents.TouchUpInside)
            contentView.addSubview(actionButton!)
        }
        
        nameLabel.font = UIFont(name: Utils().customFontSemiBold, size: 22.0)
        nameLabel.textColor = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
        nameLabel.text = "@\(user.username)"
        
        loadIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadIndicator!.tintColor = Utils().secondColor
        loadIndicator!.center = actionButton!.center
        loadIndicator!.hidesWhenStopped = true
        self.addSubview(loadIndicator!)
        
        if Utils().isUserAFriend(user){
            actionButton!.hidden = false
            actionButton!.setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
        }
        else{
            actionButton!.hidden = true
            actionButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
        }
        
    }
    
    func inviteContact(button : UIButton){
        
        loadIndicator!.startAnimating()
        self.actionButton!.hidden = true
        
        if Utils().isUserAFriend(user!){
            
            Utils().removeFriend(self.user!.objectId).continueWithBlock({ (task : BFTask!) -> AnyObject! in
                self.loadIndicator!.stopAnimating()
                if task.error != nil{
                    
                }
                else{
                    self.actionButton!.setImage(UIImage(named: "add_friends_icon"), forState: UIControlState.Normal)
                }
                
                self.actionButton!.hidden = false
                
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
                    self.actionButton!.setImage(UIImage(named: "friends_added_icon"), forState: UIControlState.Normal)
                }
                
                self.actionButton!.hidden = false
                
                return nil
                
            })
            
        }
        
    }
    
}

class ListRecipientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var getBackPikiView: UIView!
    @IBOutlet weak var pikiImageView: UIImageView!
    @IBOutlet weak var nbRecipientsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topBarView: UIView!
    
    
    var mainPiki:PFObject?
    var recipientsUser:Array<PFUser> = Array<PFUser>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Shadow Top Bar
        var stretchShadowImage:UIImage = UIImage(named: "shadow_top")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        let shadowTopBar:UIImageView = UIImageView(frame: CGRect(x: 0, y: topBarView.frame.origin.y + topBarView.frame.height, width: self.view.frame.size.width, height: 4))
        shadowTopBar.image = stretchShadowImage
        self.view.addSubview(shadowTopBar)
        
        //Back Status bar
        let backStatusBar:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 20))
        backStatusBar.backgroundColor = Utils().statusBarColor
        self.view.addSubview(backStatusBar)
        
        //Get recipients PFUser objects on the server
        getRecipients()
        
        //Get back to piki
        let gestureBack:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("backToPiki:"))
        getBackPikiView.addGestureRecognizer(gestureBack)
        
        
        //Load piki preview
        if mainPiki!["extraSmallPiki"] != nil{
            let pikiFile:PFFile = mainPiki!["extraSmallPiki"] as PFFile
            pikiFile.getDataInBackgroundWithBlock { (data, error) -> Void in
                if error == nil {
                    self.pikiImageView.image = UIImage(data: data)
                }
            }
        }
        else{
            let pikiFile:PFFile = mainPiki!["previewImage"] as PFFile
            pikiFile.getDataInBackgroundWithBlock { (data, error) -> Void in
                if error == nil {
                    self.pikiImageView.image = UIImage(data: data)
                }
            }
        }
        
        
        
        //Label with nb of people who recevied the piki
        nbRecipientsLabel.font = UIFont(name: Utils().customFontSemiBold, size: 20.0)
        let recipients = mainPiki!["recipients"] as? Array<String>
        if recipients != nil{
            let nbRecipientsFormat = String(format: NSLocalizedString("To %d people", comment : "To %d people"), recipients!.count)
            nbRecipientsLabel.text = nbRecipientsFormat
        }
        
        
        
    }
    
    func backToPiki(sender : UITapGestureRecognizer){
        
        self.navigationController!.popViewControllerAnimated(true)
        
    }
    
    

    
    
    
    func getRecipients(){

        var arrayFriendsId:Array<String>? = mainPiki!["recipients"] as? Array<String>
        
        if arrayFriendsId != nil{
            var queryFriends:PFQuery = PFUser.query()
            queryFriends.whereKey("objectId", containedIn: arrayFriendsId)
            queryFriends.orderByAscending("username")
            queryFriends.cachePolicy = kPFCachePolicyCacheThenNetwork
            
            queryFriends.findObjectsInBackgroundWithBlock { (recipients, error) -> Void in
                if error != nil {
                    
                }
                else{
                    println("Found \(recipients.count) recipients")
                    self.recipientsUser = recipients as Array<PFUser>
                    self.tableView.reloadData()
                }
            }
        }

    }

    
    
    
    
    
    /*
    * TABLE VIEW
    */
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipientsUser.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:RecipientsPikiCell = tableView.dequeueReusableCellWithIdentifier("UserRecipientCell") as RecipientsPikiCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        
        cell.loadItem(user: recipientsUser[indexPath.row])
        
        
        return cell
    }
    
    
    /*
    * Status Bar
    */
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}
