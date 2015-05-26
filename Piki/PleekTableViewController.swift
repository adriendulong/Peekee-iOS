 //
//  PleekTableViewDataSource.swift
//  Peekee
//
//  Created by Kevin CATHALY on 18/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

protocol PleekTableViewControllerDelegate: class {
    func scrollViewDidScrollToTop()
    func searchBegin()
    func searchEnd()
}
 
 enum PleekTableViewSearchingState: Int {
    case Unsearchable = 0
    case NotSearching = 1
    case SearchBeginWithoutText = 2
    case SearchBeginWithText = 3
 }

import UIKit

class PleekTableViewController: UITableViewController, InboxCellDelegate, UISearchBarDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    var toUpdate: NSIndexPath?
    
    var cancellationTokenSource = BFCancellationTokenSource()
    
    lazy var noUserView: UIView = {
        let noUV = UIView(frame: self.tableView.frame)
        noUV.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "nouser-illu")
        
        noUV.addSubview(imageView)
        
        imageView.snp_makeConstraints({ (make) -> Void in
            make.size.equalTo(105)
            make.centerX.equalTo(noUV)
            make.bottom.equalTo(noUV.snp_centerY).offset(-10.0)
        })
        
        let label = UILabel()
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.textColor = UIColor(red: 193.0/255.0, green: 204.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        label.text = LocalizedString("NO SO-CALLED\nUSER BRO")
        label.font = UIFont(name: "BanzaiBros", size: 30.0)
        
        noUV.addSubview(label)
        
        label.snp_makeConstraints({ (make) -> Void in
            make.leading.equalTo(noUV)
            make.trailing.equalTo(noUV)
            make.height.equalTo(80.0)
            make.top.equalTo(noUV.snp_centerY).offset(10.0)
        })
            
        return noUV
    } ()
    
    lazy var noPleekView: UIView = {
        let noPV = UIView(frame: self.tableView.frame)
        noPV.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "nopublicpleeks-illu")
        
        noPV.addSubview(imageView)
        
        imageView.snp_makeConstraints({ (make) -> Void in
            make.size.equalTo(105)
            make.centerX.equalTo(noPV)
            make.bottom.equalTo(noPV.snp_centerY).offset(-10.0)
        })
        
        let label = UILabel()
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.textColor = UIColor(red: 193.0/255.0, green: 204.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        label.text = LocalizedString("NO PUBLIC\nPLEEKS YET!")
        label.font = UIFont(name: "BanzaiBros", size: 30.0)
        
        noPV.addSubview(label)
        
        label.snp_makeConstraints({ (make) -> Void in
            make.leading.equalTo(noPV)
            make.trailing.equalTo(noPV)
            make.height.equalTo(80.0)
            make.top.equalTo(noPV.snp_centerY).offset(10.0)
        })
        
        return noPV
    } ()
    
    var searchState: PleekTableViewSearchingState = .NotSearching {
        didSet {
            self.cancellationTokenSource.cancel()
            self.shouldLoadMore = true
            self.tableView.backgroundView = nil
            switch self.searchState {
            case .Unsearchable, .NotSearching, .SearchBeginWithoutText:
                self.refreshControl = UIRefreshControl()
                self.refreshControl?.addTarget(self, action: Selector("refreshPleek"), forControlEvents: UIControlEvents.ValueChanged)
                self.pleeks = self.pleeksList
                break
            case .SearchBeginWithText:
                self.refreshControl = nil
                self.pleeks = self.searchList
                break
            }
            
            self.tableView.reloadData()
        }
    }
    
    var pleeksList: [Pleek] = [] {
        didSet {
            self.pleeks = self.pleeksList
            if count(self.pleeksList) > 0 && self.searchState.rawValue > PleekTableViewSearchingState.Unsearchable.rawValue {
                self.tableView.tableHeaderView = self.searchBar
            } else {
                self.tableView.tableHeaderView = nil
            }
        }
    }
    
    var searchList: [Pleek] = [] {
        didSet {
            self.pleeks = self.searchList
        }
    }
    
    private var pleeks: [Pleek] = []
    private var user: User?
    
    var dataSource: ((withCache: Bool, skip: Int, completed: PleekCompletionHandler) -> ())? {
        didSet {
            self.getPleeks(true)
        }
    }
    
    weak var delegate: PleekTableViewControllerDelegate? = nil
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView!.frame), 50)
        searchBar.barTintColor = UIColor(red: 57.0/255.0, green: 73.0/255.0, blue: 171.0/255.0, alpha: 1.0)
        searchBar.delegate = self
        
        return searchBar
    } ()
    
    var isLoadingMore: Bool = false
    var shouldLoadMore: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        self.tableView.registerClass(InboxCell.self, forCellReuseIdentifier: "InboxTableViewCellIdentifier")
        self.tableView.registerClass(LoadMoreTableViewCell.self, forCellReuseIdentifier: "LoadMoreTableViewCellIdentifier")
        self.tableView.separatorStyle = .None
        self.tableView.scrollsToTop = true
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("refreshPleek"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let toUpdate = self.toUpdate {
            self.tableView.reloadRowsAtIndexPaths([toUpdate], withRowAnimation: .Fade)
            self.toUpdate = nil
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let countPleeks = count(self.pleeks)
        
        if self.shouldLoadMore && countPleeks > 0 {
            return countPleeks + 1
        }
        
        return countPleeks
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.row == count(self.pleeks) && self.shouldLoadMore {
            let cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCellIdentifier", forIndexPath: indexPath) as! LoadMoreTableViewCell
            cell.spinner.startAnimating()
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("InboxTableViewCellIdentifier", forIndexPath: indexPath) as! InboxCell
        let pleek = self.pleeks[indexPath.row]
        cell.configureFor(pleek)
        if self.searchState == .SearchBeginWithoutText {
            cell.contentView.alpha = 0.5
        } else {
            cell.contentView.alpha = 1.0
        }
        cell.delegate = self
        
        //Load more
        if indexPath.row == count(self.pleeks) - 5 && count(self.pleeks) > 0 && !self.isLoadingMore && self.shouldLoadMore {
            self.isLoadingMore = true
            self.loadMore()
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.searchState == .SearchBeginWithoutText {
            return
        }
 
        self.toUpdate = indexPath
        let pleek = self.pleeks[indexPath.row]
        self.showPleek(pleek)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == count(self.pleeks) && self.shouldLoadMore {
            return 90
        }
        
        let pleek = self.pleeks[indexPath.row]
        let screenRect = UIScreen.mainScreen().bounds
        
        switch (pleek.state, pleek.nbReaction > 0) {
            case (.NotSeenVideo, true), (.NotSeenPhoto, true), (.SeenNewReact, true):
                return round((CGRectGetWidth(screenRect) - 12.5) / 3.0 * 2.0 + 15.0 + 90.0)
            case (.SeenNotNewReact, true):
                return round((CGRectGetWidth(screenRect) - 12.5) / 3.0 * 2.0 + 15 + 45 + 12.5)
            case (.NotSeenVideo, false), (.NotSeenPhoto, false), (.SeenNewReact, false):
                return round(CGRectGetWidth(screenRect) - 10.0 + 15.0 + 90.0)
            case (.SeenNotNewReact, false):
                return round(CGRectGetWidth(screenRect) - 10.0 + 15 + 45 + 12.5)
            default:
                return 0
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == count(self.pleeks) && self.shouldLoadMore || self.searchState.rawValue > PleekTableViewSearchingState.NotSearching.rawValue {
            return false
        }
        
        return true
    }
    
    // MARK: Others
    
    func updateList(pleeks: [Pleek]) -> [NSIndexPath] {
        var indexPathToInsert: [NSIndexPath] = []
        
        for pleek: Pleek in pleeks {
            self.pleeks.append(pleek)
            indexPathToInsert.append(NSIndexPath(forRow: count(self.pleeks) - 1, inSection: 0))
        }
        
        if count(pleeks) < Constants.LoadPleekLimit {
            self.shouldLoadMore = false
        }
        
        return indexPathToInsert
    }
    
    func updateTableView(pleeks: [Pleek]) {
        println(self.tableView)
        var indexPaths = self.updateList(pleeks)
        println(indexPaths)
        
        self.tableView.beginUpdates()
        let indexPath = indexPaths[0]
        indexPaths.removeAtIndex(0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        if self.shouldLoadMore {
            indexPaths.append(NSIndexPath(forRow: indexPaths.last!.row + 1, inSection: 0))
        }
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        self.tableView.endUpdates()
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        if let delegate = self.delegate {
            delegate.scrollViewDidScrollToTop()
        }
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: InboxCellDelegate
    
    func deletePleek(cell: InboxCell) {

        var indexPath = self.tableView.indexPathForCell(cell)
        
        if let indexPath = indexPath {
            let pleek = self.pleeks[indexPath.row]
            PleekAlertView(title: LocalizedString("Confirmation"), message: NSLocalizedString("Are you sure you want to delete this Pleek? There is no way to get back then.", comment : "Are you sure you want to delete this Pleek? There is no way to get back then."), firstButtonTitle: LocalizedString("No"),secondButtonTitle: LocalizedString("Yes"),
            firstAction: { () -> Void in
                self.pleeks.insert(pleek, atIndex: indexPath.row)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }, secondAction: { () -> Void in
                pleek.deleteOrHide({ (result, error) -> Void in
                    if let error = error {
                        PleekAlertView(title: LocalizedString("Error"), message: LocalizedString("Problem while deleting this Pleek. Please try again later."), firstButtonTitle: LocalizedString("OK"), secondButtonTitle: nil, firstAction: nil, secondAction: nil)
                        println("Error : \(error.localizedDescription)")
                    }
                })
            })
            
            self.pleeks.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK UISearchBarDelegate

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if count(searchBar.text) == 0 {
            self.searchState = .SearchBeginWithoutText
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.tableView.backgroundView = nil
        if let delegate = self.delegate {
            if count(searchText) > 0 {
                self.searchState = .SearchBeginWithText
                delegate.searchBegin()
                self.searchText(searchText)
            } else {
                delegate.searchEnd()
                NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("dismiss"), userInfo: nil, repeats: false)
            }
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        if count(self.searchBar.text) == 0 {
            self.searchState = .NotSearching
        }
    }

    func dismiss() {
        if count(self.searchBar.text) == 0 {
            self.searchState = .NotSearching
        }
        
        if self.searchBar.isFirstResponder() {
            self.searchBar.resignFirstResponder()
        }
    }
    
    // MARK: Action
    
    func showPleek(pleek: Pleek) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let pleekVC = storyboard.instantiateViewControllerWithIdentifier("PleekViewController") as? PleekViewController {
            pleekVC.mainPiki = pleek
            self.navigationController?.pushViewController(pleekVC, animated: true)
        }
    }
    
    func refreshPleek() {
        self.getPleeks(false)
    }
    
    // MARK: Data
    
    func getPleeks(withCache: Bool) {
        if let dataSource = self.dataSource {
            weak var weakSelf = self
            dataSource(withCache: withCache, skip: 0) { (pleeks, error) -> () in
                if error != nil {
                    println("Error : \(error!.localizedDescription)")
                } else {
                    if count(pleeks!) < Constants.LoadPleekLimit {
                        weakSelf?.shouldLoadMore = false
                    } else {
                        weakSelf?.shouldLoadMore = true
                    }
                    weakSelf?.pleeksList = pleeks!
                    weakSelf?.refreshControl?.endRefreshing()
                    weakSelf?.tableView.reloadData()
                    weakSelf?.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
                }
            }
        }
    }
    
    func loadMore() {
        
        if self.searchState == .SearchBeginWithText {
            self.loadMoreSearch()
        } else if let dataSource = self.dataSource {
            weak var weakSelf = self
            
            dataSource(withCache: true, skip: count(self.pleeks)) { (pleeks, error) -> () in
                weakSelf?.loadMoreResult(pleeks, error: error)
            }
        }
    }
    
    func loadMoreSearch() {
        self.cancellationTokenSource.cancel()
        self.cancellationTokenSource = BFCancellationTokenSource()
        
        weak var weakSelf = self
        
        var secondBlock: BFContinuationBlock = { (task) -> AnyObject! in
            if task.cancelled {
                println("cancelled")
            } else if let pleeks = task.result as? [Pleek] {
                weakSelf?.loadMoreResult(pleeks, error: task.error)
            }
            
            return "success"
        }
        
        if let user = self.user {
            Pleek.find(user, skip: count(self.pleeks)).continueWithBlock(secondBlock, cancellationToken: weakSelf?.cancellationTokenSource.token!)
        }
    }
    
    func loadMoreResult(pleeks: [Pleek]?, error: NSError?) {
        if let error = error {
            println("Error : \(error.localizedDescription)")
        } else if let pleeks = pleeks {
            if count(pleeks) > 0 {
                self.updateTableView(pleeks)
            } else {
                self.shouldLoadMore = false
                self.tableView.reloadData()
            }
            
        }
        self.isLoadingMore = false
    }
    
    
    func searchText(text: String) {
        self.user = nil
        
        if count(text) < 3 {
            return
        }
        
        self.cancellationTokenSource.cancel()
        self.cancellationTokenSource = BFCancellationTokenSource()
        
        weak var weakSelf = self
        
        var secondBlock: BFContinuationBlock = { (task) -> AnyObject! in
            if task.cancelled {
                println("cancelled")
            } else if let error = task.error {
                println(error)
            } else if let pleeks = task.result as? [Pleek] {
                if count(pleeks) > 0 {
                    println(pleeks)
                    weakSelf?.searchList = pleeks
                    weakSelf?.tableView.reloadData()
                } else {
                    self.tableView.backgroundView = self.noPleekView
                }
            }
            
            return "success"
        }
        
        User.find(text).continueWithBlock({ (task) -> AnyObject! in
            if let task = task {
                if task.cancelled {
                    println("cancelled")
                } else if let error = task.error {
                    println(error)
                } else if let users = task.result as? [User] {
                    println(users)
                    if count(users) > 0 {
                        weakSelf?.cancellationTokenSource = BFCancellationTokenSource()
                        weakSelf?.user = users[0]
                        Pleek.find(users[0], skip: 0).continueWithBlock(secondBlock, cancellationToken: weakSelf?.cancellationTokenSource.token!)
                    } else {
                        self.tableView.backgroundView = self.noUserView
                    }
                }
            }
            return false
        }, cancellationToken: self.cancellationTokenSource.token)
    }
}