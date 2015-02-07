//
//  FirstPageViewController.swift
//  Piki
//
//  Created by Adrien Dulong on 17/12/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation


class FirstPageViewController: UIViewController{
    
    @IBOutlet weak var catchPhraseLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        catchPhraseLabel.font = UIFont(name: Utils().customFontSemiBold, size: 30.0)
        

    }
    
    override func viewDidAppear(animated: Bool) {
        //goBig()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func goBig(){
        
        UIView.animateWithDuration(0.2,
            delay: 1,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 10,
            options: nil,
            animations: { () -> Void in
                self.nextButton.transform = CGAffineTransformMakeScale(2.0, 2.0)
        }) { (finisehd) -> Void in
            self.goSmall()
        }
        
    }
    
    func goSmall(){
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self.nextButton.transform = CGAffineTransformIdentity
            }) { (finisehd) -> Void in
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}