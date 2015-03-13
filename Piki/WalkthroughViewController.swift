//
//  WalkthroughViewController.swift
//  Pleek
//
//  Created by Adrien Dulong on 05/01/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation

class WalkthroughCollectionViewCell : UICollectionViewCell{
    
    
    var mainImageView:UIImageView?
    var textViewContainer:UIView?
    var iconImageView:UIImageView?
    var titleLabel:UILabel?
    var subtitleLabel:UILabel?
    
    var topMargin:CGFloat?
    var supSpace:CGFloat?
    var supSpaceSub:CGFloat?
    
    var lastCellView:UIView?
    var toplastCell:UIView?
    var iconLastCell:UIImageView?
    var titleLastCell:UILabel?
    var miniseparatorLastCell:UIView?
    var listInfosView:UIView?
    var firstLabelLastCell:UILabel?
    var secondLabelLastCell:UILabel?
    var thirdLabelLastCell:UILabel?
    var fourthLabelLastCell:UILabel?
    var shadowImageView:UIImageView?
    
    func loadCell(type : Int){
        
        //Background Color
        contentView.backgroundColor = UIColor(red: 48/255, green: 63/255, blue: 159/255, alpha: 1.0)
        
        if Utils().isIphone4(){
            topMargin = 0
            supSpace = 0
            supSpaceSub = 0
        }
        else if Utils().isIphone6Plus(){
            topMargin = 100
            supSpace = 40
            supSpaceSub = 30
        }
        else if Utils().isIphone5(){
            topMargin = 30
            supSpace = 10
            supSpaceSub = 0
        }
        else{
            topMargin = 60
            supSpace = 20
            supSpaceSub = 20
        }
        
        
        
        //Init Image
        if mainImageView == nil{
            mainImageView = UIImageView(frame: CGRect(x: 0, y: 20, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 55 - 20))
            mainImageView!.contentMode = UIViewContentMode.Top
            contentView.addSubview(mainImageView!)
        }
        self.mainImageView!.transform = CGAffineTransformIdentity
        
        if textViewContainer == nil{
            textViewContainer = UIView(frame: CGRect(x: 0, y: 295, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 55 - 295))
            textViewContainer!.backgroundColor = UIColor(red: 62/255, green: 80/255, blue: 180/255, alpha: 1.0)
            contentView.addSubview(textViewContainer!)
        }
        
        if iconImageView == nil{
            iconImageView = UIImageView(frame: CGRect(x: 0, y: topMargin!, width: UIScreen.mainScreen().bounds.width, height: 40))
            iconImageView!.contentMode = UIViewContentMode.Center
            textViewContainer!.addSubview(iconImageView!)
        }
        
        if subtitleLabel == nil{
            
            subtitleLabel = UILabel(frame: CGRect(x: 0, y: topMargin! + 106 + supSpace! + supSpaceSub!, width: UIScreen.mainScreen().bounds.width, height: 20))
            subtitleLabel!.numberOfLines = 1
            subtitleLabel!.adjustsFontSizeToFitWidth = true
            subtitleLabel!.font = UIFont(name: Utils().customFontNormal, size: 18)
            subtitleLabel!.textColor = UIColor(red: 121/255, green: 134/255, blue: 202/255, alpha: 1.0)
            subtitleLabel!.textAlignment = NSTextAlignment.Center
            textViewContainer!.addSubview(subtitleLabel!)
            
        }
        
        
        if titleLabel == nil{
            titleLabel = UILabel(frame: CGRect(x: UIScreen.mainScreen().bounds.width/2 - 100, y: topMargin! + 42 + supSpace!, width: 200, height: 58))
            titleLabel!.numberOfLines = 2
            titleLabel!.adjustsFontSizeToFitWidth = true
            titleLabel!.font = UIFont(name: Utils().customFontSemiBold, size: 27)
            titleLabel!.textColor = UIColor.whiteColor()
            titleLabel!.textAlignment = NSTextAlignment.Center
            textViewContainer!.addSubview(titleLabel!)
        }
        
        if shadowImageView == nil{
            //Shadow Top Bar
            var stretchShadowImage:UIImage = UIImage(named: "shadow_tuto")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            shadowImageView = UIImageView(frame: CGRect(x: 0, y: textViewContainer!.frame.origin.y - 4, width: UIScreen.mainScreen().bounds.width, height: 4))
            shadowImageView!.image = stretchShadowImage
            contentView.addSubview(shadowImageView!)
        }
        
        switch type{
        case 0:
            
            lastCellView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 55))
            lastCellView!.backgroundColor = UIColor(red: 62/255, green: 80/255, blue: 180/255, alpha: 1.0)
            contentView.addSubview(lastCellView!)
            
            toplastCell = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 22))
            toplastCell!.backgroundColor = Utils().primaryColorDark
            lastCellView!.addSubview(toplastCell!)
            
            iconLastCell = UIImageView(frame: CGRect(x: 0, y: 60, width: UIScreen.mainScreen().bounds.width, height: 36))
            iconLastCell!.contentMode = UIViewContentMode.Center
            iconLastCell!.image = UIImage(named: "cloud_icon")
            lastCellView!.addSubview(iconLastCell!)
            
            titleLastCell = UILabel(frame: CGRect(x: 0, y: iconLastCell!.frame.origin.y + iconLastCell!.frame.height + 5, width: UIScreen.mainScreen().bounds.width, height: 29))
            titleLastCell!.text = NSLocalizedString("No Bullshit.", comment : "No Bullshit.")
            titleLastCell!.textColor = UIColor.whiteColor()
            titleLastCell!.font = UIFont(name: Utils().customFontSemiBold, size: 20)
            titleLastCell!.textAlignment = NSTextAlignment.Center
            lastCellView!.addSubview(titleLastCell!)
            
            miniseparatorLastCell = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width/2 - 28, y: titleLastCell!.frame.origin.y + titleLastCell!.frame.height + 15, width: 56, height: 2))
            miniseparatorLastCell!.backgroundColor = Utils().secondColor
            lastCellView!.addSubview(miniseparatorLastCell!)
            
            listInfosView = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width/2 - 125, y: miniseparatorLastCell!.frame.origin.y + miniseparatorLastCell!.frame.height + 55, width: 250, height: 190))
            listInfosView!.backgroundColor = UIColor.clearColor()
            lastCellView!.addSubview(listInfosView!)
            
            var spaceBetweenToDo:CGFloat = 25
            if Utils().isIphone4(){
                spaceBetweenToDo = 20
            }
            else if Utils().isIphone5(){
                spaceBetweenToDo = 25
            }
            else if Utils().isIphone6Plus(){
                spaceBetweenToDo = 50
            }
            else{
                spaceBetweenToDo = 35
            }
            
            
            let checkIconOne:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            checkIconOne.image = UIImage(named: "todo_icon")
            listInfosView!.addSubview(checkIconOne)
            
            let firstLabel:UILabel = UILabel(frame: CGRect(x: checkIconOne.frame.origin.x + checkIconOne.frame.width + 20, y: checkIconOne.frame.origin.y, width: 210, height: 22))
            firstLabel.font = UIFont(name: Utils().customFontSemiBold, size: 18.0)
            firstLabel.textColor = UIColor.whiteColor()
            firstLabel.text = NSLocalizedString("Short signup", comment : "Short signup")
            listInfosView!.addSubview(firstLabel)
            
            let checkIconTwo:UIImageView = UIImageView(frame: CGRect(x: 0, y: spaceBetweenToDo + checkIconOne.frame.height, width: 24, height: 24))
            checkIconTwo.image = UIImage(named: "todo_icon")
            listInfosView!.addSubview(checkIconTwo)
            
            let secondLabel:UILabel = UILabel(frame: CGRect(x: checkIconTwo.frame.origin.x + checkIconTwo.frame.width + 20, y: checkIconTwo.frame.origin.y, width: 210, height: 22))
            secondLabel.font = UIFont(name: Utils().customFontSemiBold, size: 18.0)
            secondLabel.textColor = UIColor.whiteColor()
            secondLabel.adjustsFontSizeToFitWidth = true
            secondLabel.text = NSLocalizedString("No Facebook connect", comment : "No Facebook connect")
            listInfosView!.addSubview(secondLabel)
            
            let checkIconThree:UIImageView = UIImageView(frame: CGRect(x: 0, y: (spaceBetweenToDo + checkIconOne.frame.height) * 2, width: 24, height: 24))
            checkIconThree.image = UIImage(named: "todo_icon")
            listInfosView!.addSubview(checkIconThree)
            
            let thirdLabel:UILabel = UILabel(frame: CGRect(x: checkIconThree.frame.origin.x + checkIconThree.frame.width + 20, y: checkIconThree.frame.origin.y, width: 210, height: 22))
            thirdLabel.font = UIFont(name: Utils().customFontSemiBold, size: 18.0)
            thirdLabel.textColor = UIColor.whiteColor()
            thirdLabel.text = NSLocalizedString("No email address", comment : "No email address")
            listInfosView!.addSubview(thirdLabel)
            
            let checkIconFour:UIImageView = UIImageView(frame: CGRect(x: 0, y: (spaceBetweenToDo + checkIconOne.frame.height) * 3, width: 24, height: 24))
            checkIconFour.image = UIImage(named: "todo_icon")
            listInfosView!.addSubview(checkIconFour)
            
            let fourthLabel:UILabel = UILabel(frame: CGRect(x: checkIconFour.frame.origin.x + checkIconFour.frame.width + 20, y: checkIconFour.frame.origin.y, width: 210, height: 40))
            fourthLabel.font = UIFont(name: Utils().customFontSemiBold, size: 18.0)
            fourthLabel.textColor = UIColor.whiteColor()
            fourthLabel.numberOfLines = 2
            fourthLabel.text = NSLocalizedString("Only phone number for human verification", comment :"Only phone number for human verification")
            listInfosView!.addSubview(fourthLabel)
            

            
        default:
            lastCellView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 55))
            lastCellView!.backgroundColor = UIColor(red: 62/255, green: 80/255, blue: 180/255, alpha: 1.0)
            contentView.addSubview(lastCellView!)
            
            toplastCell = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 22))
            toplastCell!.backgroundColor = Utils().primaryColorDark
            lastCellView!.addSubview(toplastCell!)
            
            iconLastCell = UIImageView(frame: CGRect(x: 0, y: 60, width: UIScreen.mainScreen().bounds.width, height: 36))
            iconLastCell!.contentMode = UIViewContentMode.Center
            iconLastCell!.image = UIImage(named: "cloud_icon")
            lastCellView!.addSubview(iconLastCell!)
            
            titleLastCell = UILabel(frame: CGRect(x: 0, y: iconLastCell!.frame.origin.y + iconLastCell!.frame.height + 5, width: UIScreen.mainScreen().bounds.width, height: 29))
            titleLastCell!.text = NSLocalizedString("No Bullshit.", comment : "No Bullshit.")
            titleLastCell!.textColor = UIColor.whiteColor()
            titleLastCell!.font = UIFont(name: Utils().customFontSemiBold, size: 20)
            titleLastCell!.textAlignment = NSTextAlignment.Center
            lastCellView!.addSubview(titleLastCell!)
            
            miniseparatorLastCell = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width/2 - 28, y: titleLastCell!.frame.origin.y + titleLastCell!.frame.height + 15, width: 56, height: 2))
            miniseparatorLastCell!.backgroundColor = Utils().secondColor
            lastCellView!.addSubview(miniseparatorLastCell!)
            
            listInfosView = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width/2 - 125, y: miniseparatorLastCell!.frame.origin.y + miniseparatorLastCell!.frame.height + 55, width: 250, height: 190))
            listInfosView!.backgroundColor = UIColor.clearColor()
            lastCellView!.addSubview(listInfosView!)
            
            var spaceBetweenToDo:CGFloat = 25
            if Utils().isIphone4(){
                spaceBetweenToDo = 20
            }
            else if Utils().isIphone5(){
                spaceBetweenToDo = 25
            }
            else if Utils().isIphone6Plus(){
                spaceBetweenToDo = 50
            }
            else{
                spaceBetweenToDo = 35
            }
            
            
            let checkIconOne:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            checkIconOne.image = UIImage(named: "todo_icon")
            listInfosView!.addSubview(checkIconOne)
            
            let firstLabel:UILabel = UILabel(frame: CGRect(x: checkIconOne.frame.origin.x + checkIconOne.frame.width + 20, y: checkIconOne.frame.origin.y, width: 210, height: 22))
            firstLabel.font = UIFont(name: Utils().customFontSemiBold, size: 18.0)
            firstLabel.textColor = UIColor.whiteColor()
            firstLabel.text = NSLocalizedString("Short signup", comment : "Short signup")
            listInfosView!.addSubview(firstLabel)
            
            let checkIconTwo:UIImageView = UIImageView(frame: CGRect(x: 0, y: spaceBetweenToDo + checkIconOne.frame.height, width: 24, height: 24))
            checkIconTwo.image = UIImage(named: "todo_icon")
            listInfosView!.addSubview(checkIconTwo)
            
            let secondLabel:UILabel = UILabel(frame: CGRect(x: checkIconTwo.frame.origin.x + checkIconTwo.frame.width + 20, y: checkIconTwo.frame.origin.y, width: 210, height: 22))
            secondLabel.font = UIFont(name: Utils().customFontSemiBold, size: 18.0)
            secondLabel.textColor = UIColor.whiteColor()
            secondLabel.adjustsFontSizeToFitWidth = true
            secondLabel.text = NSLocalizedString("No Facebook connect", comment : "No Facebook connect")
            listInfosView!.addSubview(secondLabel)
            
            let checkIconThree:UIImageView = UIImageView(frame: CGRect(x: 0, y: (spaceBetweenToDo + checkIconOne.frame.height) * 2, width: 24, height: 24))
            checkIconThree.image = UIImage(named: "todo_icon")
            listInfosView!.addSubview(checkIconThree)
            
            let thirdLabel:UILabel = UILabel(frame: CGRect(x: checkIconThree.frame.origin.x + checkIconThree.frame.width + 20, y: checkIconThree.frame.origin.y, width: 210, height: 22))
            thirdLabel.font = UIFont(name: Utils().customFontSemiBold, size: 18.0)
            thirdLabel.textColor = UIColor.whiteColor()
            thirdLabel.text = NSLocalizedString("No email address", comment : "No email address")
            listInfosView!.addSubview(thirdLabel)
            
            let checkIconFour:UIImageView = UIImageView(frame: CGRect(x: 0, y: (spaceBetweenToDo + checkIconOne.frame.height) * 3, width: 24, height: 24))
            checkIconFour.image = UIImage(named: "todo_icon")
            listInfosView!.addSubview(checkIconFour)
            
            let fourthLabel:UILabel = UILabel(frame: CGRect(x: checkIconFour.frame.origin.x + checkIconFour.frame.width + 20, y: checkIconFour.frame.origin.y, width: 210, height: 40))
            fourthLabel.font = UIFont(name: Utils().customFontSemiBold, size: 18.0)
            fourthLabel.textColor = UIColor.whiteColor()
            fourthLabel.numberOfLines = 2
            fourthLabel.text = NSLocalizedString("Only phone number for human verification", comment :"Only phone number for human verification")
            listInfosView!.addSubview(fourthLabel)
        }
        
        
    }
    
    
    func animImage(delay : NSTimeInterval){
        
        UIView.animateWithDuration(1.5,
            delay: delay,
            options: nil,
            animations: { () -> Void in
                self.mainImageView!.transform = CGAffineTransformMakeTranslation(0, -self.mainImageView!.frame.height/2 + 20)
        }) { (finished) -> Void in
            
        }
        
    }
    
}

class WalkthroughViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{

    //UI Elements
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    var signMeUpButton:UIButton?
    @IBOutlet weak var bottomView: UIView!
    
    //Other
    var actualPosition:Int = 0
    
    
    override func viewDidLoad() {

        self.view.backgroundColor = UIColor(red: 62/255, green: 80/255, blue: 180/255, alpha: 1.0)
        
        //Sign Me Up Button Init
        let tapGestureSignUp : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("signMeUp"))
        signMeUpButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: bottomView.frame.height))
        signMeUpButton!.backgroundColor = Utils().secondColor
        signMeUpButton!.addGestureRecognizer(tapGestureSignUp)
        bottomView.addSubview(signMeUpButton!)
        
        let buttonLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: bottomView.frame.height))
        buttonLabel.font = UIFont(name: Utils().customFontSemiBold, size: 22)
        buttonLabel.textColor = UIColor.whiteColor()
        buttonLabel.textAlignment = NSTextAlignment.Center
        buttonLabel.text = NSLocalizedString("ALRIGHT, SIGN ME UP", comment :"ALRIGHT, SIGN ME UP") 
        signMeUpButton!.addSubview(buttonLabel)
        
        let arrowImageView = UIImageView(frame: CGRect(x: self.view.frame.width - 15 - 8, y: 20, width: 8, height: 14))
        arrowImageView.image = UIImage(named: "next_arrow")
        signMeUpButton!.addSubview(arrowImageView)
        
        //signMeUpButton!.transform = CGAffineTransformMakeTranslation(0, 55)
        
        //Set Layout collection view
        //Collection View Layout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 55)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView.collectionViewLayout = layout
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.backgroundColor = UIColor(red: 62/255, green: 80/255, blue: 180/255, alpha: 1.0)
        collectionView!.registerClass(WalkthroughCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView!.showsHorizontalScrollIndicator = false
        collectionView!.showsVerticalScrollIndicator = false
        collectionView!.bounces = false
        collectionView!.scrollEnabled = false

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    // MARK : Collection View DataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as WalkthroughCollectionViewCell
        
        cell.loadCell(indexPath.item)
        
        return cell
        
    }
    
    
    //MARK : Collection View Functions
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = getPositionWalk()
        
        
        //In the second screen anim image to the top
        if getPositionWalk() == 1{
            
            let cell:WalkthroughCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as WalkthroughCollectionViewCell
            cell.animImage(0.0)
            
        }
        else if getPositionWalk() == 3{
            self.collectionView!.scrollEnabled = false
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.signMeUpButton!.transform = CGAffineTransformIdentity
            }, completion: { (finished) -> Void in
            })
            
        }
    }
    
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        
        //In the second screen anim image to the top
        if actualPosition == 1{
            
            let cell:WalkthroughCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as WalkthroughCollectionViewCell
            cell.animImage(0.0)
            
        }
        else if actualPosition == 3{
            self.collectionView!.scrollEnabled = false
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.signMeUpButton!.transform = CGAffineTransformIdentity
                }, completion: { (finished) -> Void in
            })
        }

    }

    // MARK : Utils functions
    
    func getPositionWalk() -> Int{
        var position:Int = 0
        
        let indexPathVisible:Array<NSIndexPath> = collectionView!.indexPathsForVisibleItems() as Array<NSIndexPath>
        
        if indexPathVisible.count > 0{
            position = indexPathVisible[0].item
        }
        
        return position
        
    }
    
    
    // MARK : UI Actions
    
    func signMeUp(){
        self.performSegueWithIdentifier("startSignUp", sender: self)
    }
    
    @IBAction func goBack(sender: AnyObject) {
        
        let actualPosition:Int = getPositionWalk()
        
        if actualPosition > 0{
            let newPosition:Int = actualPosition - 1
            self.actualPosition = newPosition
            
            self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forItem: newPosition, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: true)
            pageControl.currentPage = newPosition
        }
        
        
    }
    
    @IBAction func goNext(sender: AnyObject) {
        
        let actualPosition:Int = getPositionWalk()
        
        if actualPosition < 3 {
            let newPosition:Int = actualPosition + 1
            self.actualPosition = newPosition
            self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forItem: newPosition, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: true)
            pageControl.currentPage = newPosition
        }
        
    }
    
    
}
