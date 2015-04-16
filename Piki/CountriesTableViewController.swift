//
//  CountriesTableViewController.swift
//  Piki
//
//  Created by Adrien Dulong on 17/11/2014.
//  Copyright (c) 2014 PikiChat. All rights reserved.
//

import Foundation

protocol CountriesControllerProtocol {
    func choseCountry(countryChoiceInfos : [String : String])
}

class CountriesTableViewController : UITableViewController{
    
    var delegate:CountriesControllerProtocol? = nil
    var countriesInfos:Array<[String : String]> = Array<[String : String]>()
    
    @IBOutlet weak var quitButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.barTintColor = Utils().primaryColor
        quitButton.tintColor = UIColor.whiteColor()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "countryCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func quit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("quit")
        })
    }
    
    /*
    * Table View
    */
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countriesInfos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("countryCell") as! UITableViewCell
        
        cell.textLabel?.text = countriesInfos[indexPath.row]["countryName"]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var countryName = countriesInfos[indexPath.row]["countryName"]
        println("country selected : \(countryName)")
        
        
        self.delegate!.choseCountry(countriesInfos[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
}