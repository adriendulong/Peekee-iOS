//
//  TransitionManager.swift
//  Piki
//
//  Created by Adrien Dulong on 19/11/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import UIKit

class TransitionManager: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning  {
    
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    //To know if we are presenting a screen or dismissing it
    var presenting:Bool = true
    private var interactive = false
    
    // private so can only be referenced within this object
    private var enterPanGesture: UIPanGestureRecognizer!
    
    // not private, so can also be used from other objects :)
    var sourceViewController: TakePhotoViewController!{
        didSet {
            self.enterPanGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
            self.sourceViewController.view.addGestureRecognizer(self.enterPanGesture)
        }
    }
    
    // animate a change from one viewcontroller to another
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        
        
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView()
        
        
        let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!, transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
        
        let menuViewController = self.presenting ? screens.from as MainViewController : screens.to as MainViewController
        let takePhotoController = self.presenting ? screens.to as TakePhotoViewController : screens.from as TakePhotoViewController
        
        let mainView = menuViewController.view
        let takePhotoView = takePhotoController.view
        
        
        // set up from 2D transforms that we'll use in the animation
        let offScreenRight = CGAffineTransformMakeTranslation(container.frame.width, 0)
        let offScreenLeft = CGAffineTransformMakeTranslation(-container.frame.width, 0)
        
        let offScreenTop = CGAffineTransformMakeTranslation(0, -container.frame.height)
        let offScreenBottom =  CGAffineTransformMakeTranslation(0, container.frame.height)
        
        let inMainScreen = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, 30), CGAffineTransformMakeScale(0.9, 0.9))
        
        if !self.presenting{
            menuViewController.transitionView!.hidden = false
            menuViewController.transitionView!.alpha = 0.8
        }
        
        // start the toView to the right of the screen
        takePhotoView.transform = self.presenting ? CGAffineTransformMakeTranslation(0, container.frame.height) : CGAffineTransformIdentity
        
        mainView.transform = self.presenting ? CGAffineTransformIdentity : inMainScreen

        // add the both views to our view controller
        
        container.addSubview(mainView)
        container.addSubview(takePhotoView)
        
        
        let duration = self.transitionDuration(transitionContext)
        

        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: nil, animations: { () -> Void in
            
            takePhotoView.transform = self.presenting ? CGAffineTransformIdentity : offScreenBottom
            mainView.transform = CGAffineTransformIdentity
            
            if !self.presenting{
                menuViewController.transitionView!.alpha = 0.0
            }
            
        }) { (finished) -> Void in
            menuViewController.transitionView!.hidden = true
            
            if transitionContext.transitionWasCancelled(){
                takePhotoController.prefersStatusBarHidden()
                transitionContext.completeTransition(false)
                 UIApplication.sharedApplication().keyWindow?.addSubview(screens.from.view)
            }
            else{
                takePhotoController.captureSession.stopRunning()
                transitionContext.completeTransition(true)
                UIApplication.sharedApplication().keyWindow?.addSubview(screens.to.view)
            }
            
            
        }

    }
    
    // return how many seconds the transiton animation will take
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animataor when presenting a viewcontroller
    // remmeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return self.interactive ? self : nil
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
    func handleOnstagePan(pan: UIPanGestureRecognizer){
        let translation = pan.translationInView(pan.view!)
        
        let d = translation.y/CGRectGetHeight(pan.view!.bounds)
        println("D : \(d)")
        
        
        /*
        switch pan.state{
            
        case UIGestureRecognizerState.Began:
            self.interactive = true
            self.sourceViewController.performSegueWithIdentifier("returnToMainMenu", sender: self)
            break
            
        case UIGestureRecognizerState.Changed:
            
            self.updateInteractiveTransition(d)
            break
            
        default:
            self.interactive = false
            self.finishInteractiveTransition()
            
        }
*/
    }
    
    
    func handlePan(pan : UIPanGestureRecognizer){
        let translation = pan.translationInView(pan.view!)
        
        let d = translation.y/CGRectGetHeight(pan.view!.bounds)*0.8
        
        
        switch pan.state{
            
        case UIGestureRecognizerState.Began:
            self.interactive = true
            self.sourceViewController.performSegueWithIdentifier("returnToMainMenu", sender: self)
            break
            
        case UIGestureRecognizerState.Changed:
            
            if d > 0.1{
                self.sourceViewController.cameraTextView!.resignFirstResponder()
            }
            self.updateInteractiveTransition(d)
            break

        default:
            self.interactive = false
            if d > 0.3
            {
                self.finishInteractiveTransition()
            }
            else{
                self.cancelInteractiveTransition()
            }
            
        }
    }


    
}