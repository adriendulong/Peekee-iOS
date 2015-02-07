//
//  EditUsernameViewController.swift
//  Peekee
//
//  Created by Adrien Dulong on 17/01/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import Foundation


class EditUsernameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!

    
    override func viewDidLoad() {
        
        titleLabel.text = NSLocalizedString("Edit username", comment : "Edit username")
        
        let backStatusBar:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        backStatusBar.backgroundColor = Utils().statusBarColor
        self.view.addSubview(backStatusBar)
        
        usernameTextField.tintColor = Utils().secondColor
        usernameTextField.autocorrectionType = UITextAutocorrectionType.No
        usernameTextField.becomeFirstResponder()
        
    }
    
    
    // MARK: Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: Actions functions
    
    @IBAction func leaveEdit(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func validateUsername(sender: AnyObject) {
        verifyUsernameAvailable()
    }
    
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //Verify Username
        verifyUsernameAvailable()
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        if isForbidden(string){
            return false
        }
        
        return true
        
    }
    
    // MARK : Forbidden characters for username
    
    func isForbidden(string : String) -> Bool{
        
        let forbiddenCharacters : Array<String> = ["@", " ", "/", "!", "#"]
        
        if contains(forbiddenCharacters, string){
            return true
        }
        else{
            return false
        }
    }
    
    
    
    // MARK: Function to verify username
    
    func verifyUsernameAvailable(){
        
        
        
        
        var finalText:NSString = usernameTextField.text as NSString

        if finalText.length > 2{
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            var finalString:String = finalText as String!
            finalString.lowercaseString
            
            if Utils().usernameValid(finalString){
                var userQuery:PFQuery = PFUser.query()
                userQuery.whereKey("username", equalTo: finalString.lowercaseString)
                userQuery.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
                    if error == nil {
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                        //Username already exists
                        if users.count > 0{
                            let alert = UIAlertView(title: "Error", message: NSLocalizedString("Sorry but this username is already taken. Please choose an other one", comment :"Sorry but this username is already taken. Please choose an other one"),
                                delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        }
                        else{
                            //Change Username
                            println("change username")
                            
                            var currentUser = PFUser.currentUser()
                            currentUser.username = finalText
                            currentUser.password = finalText
                            
                            currentUser.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                                if error != nil{
                                    println("Error : \(error.localizedDescription)")
                                    let alert = UIAlertView(title: "Error", message: NSLocalizedString("Problem while updating your username. Please try again later.", comment :"Problem while updating your username. Please try again later."),
                                        delegate: nil, cancelButtonTitle: "OK")
                                    alert.show()
                                }
                                else{
                                    self.navigationController?.popViewControllerAnimated(true)
                                }
                            })
                            
                        }
                        
                    }
                    else{
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                        let alert = UIAlertView(title: "Error", message: NSLocalizedString("Problem while updating your username. Please try again later.", comment :"Problem while updating your username. Please try again later."),
                            delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                })
            }
            else{
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                let alert = UIAlertView(title: "Error", message: NSLocalizedString("Your username can only have letters and numbers.", comment :"Your username can only have letters and numbers."),
                    delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            
            
        }
        else{
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            let alert = UIAlertView(title: "Error", message: NSLocalizedString("Your username must have at least 3 characters.", comment :"Your username must have at least 3 characters."),
                delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        
        
    }
}
