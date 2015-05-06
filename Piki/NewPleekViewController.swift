//
//  NewPleekViewController.swift
//  Peekee
//
//  Created by Kevin CATHALY on 05/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import UIKit

protocol NewPleekViewControllerDelegate {
    func dismissKeyboard()
    func presentKeyboard()
    func startRecording()
    func endRecording()
    func toName1()
    func toName2(imageData: NSData)
    func toName3(indexPath: NSIndexPath)
}

class NewPleekViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PBJVisionDelegate {
    
    var collectionShown:Int = 0
    var memeCellSelected:Int?
    var textCellSelected:Int?
    var mems : Array<PFObject> = Array<PFObject>()
    var delegate: NewPleekViewControllerDelegate? = nil
    var isTakingPhoto: Bool = false
    var isRecording: Bool = false
    var imageFile:PFFile?
    var pleekManager: PleekManager = PleekManager()
    
    lazy var cameraMenuView: UIView = {
        var tmpCameraMenuView: UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 95))
        
        tmpCameraMenuView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(tmpCameraMenuView)

        tmpCameraMenuView.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            make.height.equalTo(Dimensions.NewPleekMenuHeight)
            make.top.equalTo(self.tutorialView.snp_bottom).offset(20)
        }
        
        return tmpCameraMenuView
    }()
    
    lazy var backgroundBaseTab: UIView = {
        var tmpBackgroundBaseTab: UIView = UIView(frame: CGRectZero)
        
        tmpBackgroundBaseTab.backgroundColor = UIColor.Theme.BackgroundNewPleekMenuColor
        self.cameraMenuView.addSubview(tmpBackgroundBaseTab)
        
        tmpBackgroundBaseTab.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.cameraMenuView.snp_leading)
            make.trailing.equalTo(self.cameraMenuView.snp_trailing)
            make.top.equalTo(self.cameraMenuView.snp_top).offset(45)
            make.height.equalTo(Dimensions.BackgroundBaseTabHeight)
        }
        
        return tmpBackgroundBaseTab
    }()
    
    lazy var changeCameraButton: UIButton = {
        var tmpChangeCameraButton: UIButton = UIButton(frame: CGRectZero)

        if PBJVision.sharedInstance().cameraDevice == PBJCameraDevice.Front{
            tmpChangeCameraButton.setImage(UIImage(named: "selfie"), forState: UIControlState.Normal)
        } else{
            tmpChangeCameraButton.setImage(UIImage(named: "landscape"), forState: UIControlState.Normal)
        }
        
        tmpChangeCameraButton.tag = 1
        tmpChangeCameraButton.addTarget(self, action: Selector("selectCameraMode:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.leftPart.addSubview(tmpChangeCameraButton)
        
        tmpChangeCameraButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.leftPart.snp_top)
            make.leading.equalTo(self.leftPart.snp_leading)
            make.trailing.equalTo(self.leftPart.snp_centerX)
            make.bottom.equalTo(self.leftPart.snp_bottom)
        }
        
        return tmpChangeCameraButton
    }()
    
    lazy var keyboardButton: UIButton = {
        var tmpKeyboardButton: UIButton = UIButton(frame: CGRectZero)
        
        tmpKeyboardButton.setImage(UIImage(named: "keyboard_icon"), forState: UIControlState.Normal)
        tmpKeyboardButton.setImage(UIImage(named: "keyboard_selected_icon"), forState: UIControlState.Selected)
        tmpKeyboardButton.tag = 2
        tmpKeyboardButton.addTarget(self, action: Selector("selectCameraMode:"), forControlEvents: UIControlEvents.TouchUpInside)
        tmpKeyboardButton.selected = true
        
        self.leftPart.addSubview(tmpKeyboardButton)
        
        tmpKeyboardButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.leftPart.snp_top)
            make.leading.equalTo(self.leftPart.snp_centerX)
            make.trailing.equalTo(self.leftPart.snp_trailing)
            make.bottom.equalTo(self.leftPart.snp_bottom)
        }
        
        return tmpKeyboardButton
    }()
    
    lazy var leftPart: UIView = {
        var tmpLeftPart = UIView(frame: CGRectZero)
        
        self.backgroundBaseTab.addSubview(tmpLeftPart)
        
        tmpLeftPart.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.backgroundBaseTab.snp_top)
            make.leading.equalTo(self.backgroundBaseTab.snp_leading).offset(10)
            make.trailing.equalTo(self.cameraMenuPhotoButton.snp_leading)
            make.bottom.equalTo(self.backgroundBaseTab.snp_bottom)
        }
        
        return tmpLeftPart
    }()
    
    lazy var textButton: UIButton = {
        var tmpTextButton: UIButton = UIButton(frame: CGRectZero)
        
        tmpTextButton.setImage(UIImage(named: "font_icon"), forState: UIControlState.Normal)
        tmpTextButton.setImage(UIImage(named: "font_icon_selected"), forState: UIControlState.Selected)
        tmpTextButton.tag = 3
        tmpTextButton.addTarget(self, action: Selector("selectCameraMode:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.rightPart.addSubview(tmpTextButton)
        
        tmpTextButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.rightPart.snp_top)
            make.trailing.equalTo(self.rightPart.snp_centerX)
            make.leading.equalTo(self.rightPart.snp_leading)
            make.bottom.equalTo(self.rightPart.snp_bottom)
        }
        
        return tmpTextButton
    }()
    
    lazy var memeButton: UIButton = {
        var tmpMemeButton: UIButton = UIButton(frame: CGRectZero)

        tmpMemeButton.setImage(UIImage(named: "stickers_icon"), forState: UIControlState.Normal)
        tmpMemeButton.setImage(UIImage(named: "stickers_icon_selected"), forState: UIControlState.Selected)
        tmpMemeButton.tag = 4
        tmpMemeButton.addTarget(self, action: Selector("selectCameraMode:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.rightPart.addSubview(tmpMemeButton)
        
        tmpMemeButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.rightPart.snp_top)
            make.leading.equalTo(self.rightPart.snp_centerX)
            make.trailing.equalTo(self.rightPart.snp_trailing)
            make.bottom.equalTo(self.rightPart.snp_bottom)
        }
        
        return tmpMemeButton
        }()
    
    lazy var rightPart: UIView = {
        
        var tmpRightPart = UIView(frame: CGRectZero)
        self.backgroundBaseTab.addSubview(tmpRightPart)
        
        tmpRightPart.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.backgroundBaseTab.snp_top)
            make.leading.equalTo(self.cameraMenuPhotoButton.snp_trailing)
            make.trailing.equalTo(self.backgroundBaseTab.snp_trailing).offset(-10)
            make.bottom.equalTo(self.backgroundBaseTab.snp_bottom)
        }
        
        return tmpRightPart
    }()
    
    lazy var backCamera: UIImageView = {
        var tmpBackCamera: UIImageView = UIImageView(frame: CGRectZero)
        tmpBackCamera.image = UIImage(named: "reply_button_background")
        
        self.cameraMenuView.addSubview(tmpBackCamera)
        
        tmpBackCamera.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.cameraMenuView.snp_top)
            make.size.equalTo(85)
            make.centerX.equalTo(self.cameraMenuView.snp_centerX)
        }
        
        return tmpBackCamera
    }()
    
    lazy var cameraMenuPhotoButton: UIButton = {
        var tmpCameraMenuPhotoButton: UIButton = UIButton(frame: CGRectZero)
        
        var tapGestureTakPhoto:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("takePhoto"))
        var longGestureRecordVideo:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("recordVideo:"))
        
        longGestureRecordVideo.minimumPressDuration = 0.4
        
        tmpCameraMenuPhotoButton.setImage(UIImage(named: "reply_button"), forState: UIControlState.Normal)
        tmpCameraMenuPhotoButton.setImage(UIImage(named: "reply_button_selected"), forState: UIControlState.Selected)
        tmpCameraMenuPhotoButton.addGestureRecognizer(tapGestureTakPhoto)
        tmpCameraMenuPhotoButton.addGestureRecognizer(longGestureRecordVideo)
        self.cameraMenuView.addSubview(tmpCameraMenuPhotoButton)
        
        tmpCameraMenuPhotoButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(10)
            make.size.equalTo(65)
            make.centerX.equalTo(self.cameraMenuView.snp_centerX)
        }
        
        return tmpCameraMenuPhotoButton
    }()
    
    lazy var tutorialView: UIView = {
        var tmpTutorialView: UIView = UIView(frame: CGRectZero)
        
        tmpTutorialView.backgroundColor = UIColor.clearColor()
        tmpTutorialView.alpha = 0.0
        
        self.view.addSubview(tmpTutorialView)
        
        tmpTutorialView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view.snp_centerX)
            make.width.equalTo(150)
            make.height.equalTo(40)
            make.top.equalTo(self.view.snp_top)
        }
        
        return tmpTutorialView
    }()
    

    lazy var backImageTutoriel: UIImageView = {
        var tmpBackImageTutoriel: UIImageView = UIImageView(frame: CGRectZero)
    
        tmpBackImageTutoriel.contentMode = UIViewContentMode.Center
        tmpBackImageTutoriel.image = UIImage(named: "tutorial_background")
        
        self.tutorialView.addSubview(tmpBackImageTutoriel)
        
        tmpBackImageTutoriel.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.tutorialView.snp_leading)
            make.trailing.equalTo(self.tutorialView.snp_trailing)
            make.top.equalTo(self.tutorialView.snp_top)
            make.bottom.equalTo(self.tutorialView.snp_bottom)
        }
        
        return tmpBackImageTutoriel
    }()
    
    lazy var textTuto: UILabel = {
        var tmpTextTuto: UILabel = UILabel(frame: CGRectZero)

        tmpTextTuto.textAlignment = NSTextAlignment.Center
        tmpTextTuto.font = UIFont(name: Utils().montserratRegular, size: 11)
        let string:NSString = "TAP LONG FOR VIDEO" as NSString
        let firstAttributes = [NSForegroundColorAttributeName: UIColor(red: 136/255, green: 146/255, blue: 159/255, alpha: 1.0)]
        let secondAttributes = [NSForegroundColorAttributeName: UIColor(red: 36/255, green: 35/255, blue: 35/255, alpha: 1.0)]
        var attributedString = NSMutableAttributedString(string: string as String)
        attributedString.addAttributes(firstAttributes, range: string.rangeOfString("TAP LONG FOR"))
        attributedString.addAttributes(secondAttributes, range: string.rangeOfString("VIDEO"))
        tmpTextTuto.attributedText = attributedString
        
        self.tutorialView.addSubview(tmpTextTuto)
        
        tmpTextTuto.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.tutorialView.snp_leading)
            make.trailing.equalTo(self.tutorialView.snp_trailing)
            make.top.equalTo(self.tutorialView.snp_top)
            make.bottom.equalTo(self.tutorialView.snp_bottom).offset(-5)
        }
        
        return tmpTextTuto
    }()
    
    lazy var memCollectionView: UICollectionView = {
       
        //Collection View Layout
        let layoutMem: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutMem.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
        layoutMem.minimumInteritemSpacing = 1
        layoutMem.minimumLineSpacing = 1
        layoutMem.scrollDirection = UICollectionViewScrollDirection.Horizontal
        var tmpMemCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layoutMem)
        self.view.addSubview(tmpMemCollectionView)
        tmpMemCollectionView.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            make.top.equalTo(self.cameraMenuView.snp_bottom)
            make.bottom.equalTo(self.view.snp_bottom)
        }
        
        
        tmpMemCollectionView.registerClass(MemCollectionViewCell.self, forCellWithReuseIdentifier: "CellMem")
        tmpMemCollectionView.backgroundColor = UIColor(red: 42/255, green: 41/255, blue: 41/255, alpha: 1.0)
        tmpMemCollectionView.dataSource = self
        tmpMemCollectionView.delegate = self
        tmpMemCollectionView.showsHorizontalScrollIndicator = false
        tmpMemCollectionView.showsVerticalScrollIndicator = false

        
        return tmpMemCollectionView
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupView()
    }
    
    func setupView() {
        let vvv = self.backCamera
        let vv = self.keyboardButton
        let fff = self.changeCameraButton
        let tt = self.memeButton
        let ll = self.textButton
        let ee = self.backImageTutoriel
        let dd = self.textTuto
        
        
        self.memCollectionView.reloadData()
    }

    
    func unSelectExcept(sender: UIButton) {
        if sender != keyboardButton && sender != changeCameraButton {
            keyboardButton.selected = false
        }
        
        if sender != textButton && sender != changeCameraButton {
            textButton.selected = false
        }
        
        if sender != memeButton && sender != changeCameraButton {
            memeButton.selected = false
        }
    }
    
    func selectCameraMode(sender : UIButton) {

        self.unSelectExcept(sender)
        
        switch sender {
            case changeCameraButton:
                var vision:PBJVision = PBJVision.sharedInstance()
                
                if vision.cameraDevice == PBJCameraDevice.Front{
                    vision.cameraDevice = PBJCameraDevice.Back
                }
                else{
                    vision.cameraDevice = PBJCameraDevice.Front
                }
                break
            case keyboardButton:
                getBackToKeyboardMode()
                break
            case textButton:
                
                if sender.selected {
                    getBackToKeyboardMode()
                }
                else {
                    sender.selected = true
                    self.collectionShown = 1
                    self.memCollectionView.reloadData()
                    if let delegate = self.delegate {
                        delegate.dismissKeyboard()
                    }
                }
                break
            case memeButton:
                if sender.selected {
                    getBackToKeyboardMode()
                }
                else{
                    sender.selected = true
                    textButton.selected = false
                    self.collectionShown = 2
                    self.memCollectionView.reloadData()
                    
                    if let delegate = self.delegate {
                        delegate.dismissKeyboard()
                    }
                }
                break
            default:
                println("not known")
                break
        }
    }
    
    func getBackToKeyboardMode(){
        self.collectionShown = 0
        keyboardButton.selected = true
        
        if let delegate = self.delegate {
            delegate.presentKeyboard()
        }
    }

    // MARK: Mem
    
    func getLastMem(){
        var queryMem:PFQuery = PFQuery(className: "stickers")
        queryMem.orderByAscending("priorite")
        queryMem.cachePolicy = PFCachePolicy.CacheThenNetwork
        queryMem.findObjectsInBackgroundWithBlock { (mems, error) -> Void in
            if error != nil {
                
            }
            else {
                self.mems = mems as! Array<PFObject>
                self.memCollectionView.reloadData()
            }
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.collectionShown == 2 {
            return self.mems.count
        }
        else if self.collectionShown == 1 {
            return Utils().getFontsWithSize(30).count
        }
        else {
            return 0
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size: CGFloat = (CGRectGetHeight(self.view.frame) - 95.0 - 60.0) / 2 - 1
        
        return CGSize(width: size, height: size)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0)
    }*/
    //Build each cell
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellMem", forIndexPath: indexPath) as! MemCollectionViewCell
        
        if self.collectionShown == 2 {
            cell.iconImageView.hidden = false
            cell.labelDemoFont.hidden = true
            cell.iconImageView.image = nil
            
            
            cell.selectorImageView.hidden = true
            cell.innerShadowImageView.hidden = true
            cell.contentView.backgroundColor = UIColor(red: 53/255, green: 54/255, blue: 55/255, alpha: 1.0)
            
            
            if self.memeCellSelected != nil{
                if indexPath.item == self.memeCellSelected {
                    cell.selectorImageView.hidden = false
                    cell.innerShadowImageView.hidden = false
                    cell.contentView.backgroundColor = UIColor(red: 47/255, green: 47/255, blue: 48/255, alpha: 1.0)
                }
                else{
                    if cell.iconImageView.image == nil {
                        cell.loadIndicator.startAnimating()
                    }
                }
            }
            else{
                
                if let delegate = self.delegate {
                    delegate.toName1()
                }
                
                if cell.iconImageView.image == nil {
                    cell.loadIndicator.startAnimating()
                }
            }
            
            var fileMem = self.mems[indexPath.item]["image"] as! PFFile
            fileMem.getDataInBackgroundWithBlock({ (data, error) -> Void in
                cell.loadIndicator.stopAnimating()
                
                if let imageData = data{
                    cell.iconImageView.image = UIImage(data: imageData)
                    
                    if self.memeCellSelected != nil{
                        if indexPath.item == self.memeCellSelected{
                            if let delegate = self.delegate {
                                delegate.toName2(imageData)
                            }
                        }
                    }
                } 
            })
        }
        else {
            cell.iconImageView.hidden = true
            cell.labelDemoFont.font = Utils().getFontsWithSize(30)[indexPath.item]["font"] as! UIFont
            cell.labelDemoFont.textColor = Utils().getFontsWithSize(30)[indexPath.item]["color"] as! UIColor
            cell.labelDemoFont.hidden = false
            cell.loadIndicator.stopAnimating()
            
            
            cell.selectorImageView.hidden = true
            cell.innerShadowImageView.hidden = true
            cell.contentView.backgroundColor = UIColor(red: 53/255, green: 54/255, blue: 55/255, alpha: 1.0)
            
            if self.textCellSelected != nil{
                if indexPath.item == self.textCellSelected {
                    cell.selectorImageView.hidden = false
                    cell.innerShadowImageView.hidden = false
                    cell.contentView.backgroundColor = UIColor(red: 47/255, green: 47/255, blue: 48/255, alpha: 1.0)
                    
                    if let delegate = self.delegate {
                        delegate.toName3(indexPath)
                    }
                }
            }
        }
  
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if self.collectionShown == 2 {
            var oldCellSelected:Int?
            if self.memeCellSelected != nil {
                if self.memeCellSelected! == indexPath.item {
                    self.memeCellSelected = nil
                }
                else {
                    oldCellSelected = self.memeCellSelected
                    self.memeCellSelected = indexPath.item
                    
                }
            }
            else {
                self.memeCellSelected = indexPath.item
            }
            
            var indexPathToReload:[NSIndexPath] = [NSIndexPath]()
            if oldCellSelected != nil{
                indexPathToReload.append(NSIndexPath(forItem: oldCellSelected!, inSection: 0))
            }
            
            indexPathToReload.append(indexPath)
            self.memCollectionView.reloadItemsAtIndexPaths(indexPathToReload)
        }
        else {
            var oldCellSelected:Int?
            if self.textCellSelected != nil {
                if self.textCellSelected! == indexPath.item {
                    self.textCellSelected = nil
                }
                else {
                    oldCellSelected = self.textCellSelected
                    self.textCellSelected = indexPath.item
                    
                }
            }
            else {
                self.textCellSelected = indexPath.item
            }
            
            var indexPathToReload:[NSIndexPath] = [NSIndexPath]()
            if oldCellSelected != nil {
                indexPathToReload.append(NSIndexPath(forItem: oldCellSelected!, inSection: 0))
            }
            
            indexPathToReload.append(indexPath)
            self.memCollectionView.reloadItemsAtIndexPaths(indexPathToReload)
        }
    }
    
    

    
    // MARK: TAKE PHOTO
    
    func takePhoto(){
        println("takePhoto")
        isTakingPhoto = true
        PBJVision.sharedInstance().startVideoCapture()
    }
    
    // MARK: PBJVisionDelegate
    
    func visionCameraDeviceWillChange(vision: PBJVision) {
        if PBJVision.sharedInstance().cameraDevice == PBJCameraDevice.Front{
            self.changeCameraButton.setImage(UIImage(named: "landscape-switch"), forState: UIControlState.Normal)
        }
        else{
            self.changeCameraButton.setImage(UIImage(named: "selfie-switch"), forState: UIControlState.Normal)
        }
    }
    
    func visionCameraDeviceDidChange(vision: PBJVision) {
        if PBJVision.sharedInstance().cameraDevice == PBJCameraDevice.Front{
            self.changeCameraButton.setImage(UIImage(named: "selfie"), forState: UIControlState.Normal)
        }
        else{
            self.changeCameraButton.setImage(UIImage(named: "landscape"), forState: UIControlState.Normal)
        }
    }
    
    func vision(vision: PBJVision, capturedPhoto photoDict: [NSObject : AnyObject]?, error: NSError?) {
        
        if error != nil{
            //Alert and return
            return
        }
        
        var photoData:NSData? = photoDict![PBJVisionPhotoJPEGKey] as? NSData
        
        if photoData != nil {
            self.pleekManager.uploadNewReact(photoData!)
        }
        else {
            //Alert and return
            return
        }
    }
    
    //MARK: RECORD VIDEO
    
    func visionDidStartVideoCapture(vision: PBJVision) {
        println("Frame rate : \(PBJVision.sharedInstance().videoFrameRate), bit rate : \(PBJVision.sharedInstance().videoBitRate)")
        if isTakingPhoto{
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("endTakePicture"), userInfo: nil, repeats: false)
        }
        else {
            if let delegate = self.delegate {
                delegate.startRecording()
            }
        }
    }
    
    func endTakePicture() {
        PBJVision.sharedInstance().endVideoCapture()
    }
    
    func visionDidEndVideoCapture(vision: PBJVision) {
        if !self.isTakingPhoto {
            if let delegate = self.delegate {
                delegate.endRecording()
            }
        }
    }
    
    func visionCameraModeDidChange(vision: PBJVision) {

    }
    
    func startRecordVideo(){
        PBJVision.sharedInstance().startVideoCapture()
    }
    
    
    func recordVideo(longGesture:UILongPressGestureRecognizer){
        switch longGesture.state{
            
        case UIGestureRecognizerState.Began:
            
            self.tutorialView.alpha = 0.0
            Utils().justSeeVideoTuto()
            
            self.isTakingPhoto = false
            self.cameraMenuPhotoButton.selected = true
            PBJVision.sharedInstance().startVideoCapture()
 
        case UIGestureRecognizerState.Ended:
            self.cameraMenuPhotoButton.selected = false
            println("PBJVision : \(PBJVision.sharedInstance())")
            
            if PBJVision.sharedInstance().recording{
                println("End Record")
                PBJVision.sharedInstance().endVideoCapture()
            }
            
        default:
            println("problem")
        }
    }
    
    func vision(vision: PBJVision, capturedVideo videoDict: [NSObject : AnyObject]?, error: NSError?) {
        self.isRecording = false
        if error != nil {
            //ALERT PROBLEM RECORDING VIDEO
            println("PROBLEM : \(error?.description)")
        }
        else {
            var videoPath:NSString? = videoDict![PBJVisionVideoPathKey] as? NSString
            
            if isTakingPhoto{
                let screenImage:UIImage = Utils().getImageFrameFromVideoBeginning(NSURL(fileURLWithPath: videoPath as! String)!)
                isTakingPhoto = false
                self.pleekManager.uploadNewReact(UIImageJPEGRepresentation(screenImage, 1.0))
            }
            else{
                if videoPath != nil{
                    println("Video Path : \(videoPath!)")
                    
                    self.pleekManager.uploadNewVideoReact(videoPath!)
                }
            }
        }
    }
}