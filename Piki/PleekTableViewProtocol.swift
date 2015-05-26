 //
//  PleekTableViewDataSource.swift
//  Peekee
//
//  Created by Kevin CATHALY on 18/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

protocol PleekTableViewDelegate: class {
    func pleekTableView(tableView: UITableView?, didSelectPleek pleek:Pleek, atIndexPath indexPath: NSIndexPath?)
    func pleekTableViewLoadMore(pleekProtocol: PleekTableViewProtocol, tableView: UITableView, toSkip: Int)
    func pleekTableViewResultSearchTextChange(pleekProtocol: PleekTableViewProtocol, tableView: UITableView, text: String, skip: Int)
    func scrollViewDidScrollToTop()
    func searchBegin(tableView: UITableView?)
    func searchEnd(tableView: UITableView?)
}
 
 enum PleekTableViewSearchingState: Int {
    case Unsearchable = 0
    case NotSearching = 1
    case SearchBeginWithoutText = 2
    case SearchBeginWithText = 3
 }

import UIKit

class PleekTableViewProtocol: NSObject, UITableViewDataSource, UITableViewDelegate, InboxCellDelegate, UISearchBarDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    var searchState: PleekTableViewSearchingState {
        didSet {
            switch self.searchState {
            case .Unsearchable, .NotSearching, .SearchBeginWithoutText :
                self.pleeks = self.pleeksList
                break
            case .SearchBeginWithText:
                self.pleeks = self.searchList
                break
            }
            
            self.tableView?.reloadData()
        }
    }
    
    var pleeksList: [Pleek] = [] {
        didSet {
            self.pleeks = self.pleeksList
            if count(self.pleeksList) > 0 && self.searchState.rawValue > PleekTableViewSearchingState.Unsearchable.rawValue {
                self.tableView?.tableHeaderView = self.searchBar
            } else {
                self.tableView?.tableHeaderView = nil
            }
        }
    }
    
    var searchList: [Pleek] = [] {
        didSet {
            self.pleeks = self.searchList
        }
    }
    
    private var pleeks: [Pleek] = []
    
    weak var tableView: UITableView?
    
    weak var delegate: PleekTableViewDelegate? = nil
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView!.frame), 50)
        searchBar.barTintColor = UIColor(red: 57.0/255.0, green: 73.0/255.0, blue: 171.0/255.0, alpha: 1.0)
        searchBar.delegate = self
        
        return searchBar
    } ()
    
    var isLoadingMore: Bool = false
    var shouldLoadMore: Bool = true

    init(searchState: PleekTableViewSearchingState) {
        self.searchState = searchState
        
        super.init()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let countPleeks = count(self.pleeks)
        
        if self.shouldLoadMore && countPleeks > 0{
            return countPleeks + 1
        }
        
        return countPleeks
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

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
            if let delegate = self.delegate {
                weak var weakSelf = self
                self.isLoadingMore = true
                delegate.pleekTableViewLoadMore(weakSelf!, tableView: tableView, toSkip: count(self.pleeks))
            }
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.searchState == .SearchBeginWithoutText {
            return
        }
        
        if let delegate = self.delegate {
            delegate.pleekTableView(tableView, didSelectPleek: self.pleeks[indexPath.row], atIndexPath: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
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
    
    func updateTableView(tableView: UITableView,  pleeks: [Pleek]) {
        var indexPaths = self.updateList(pleeks)
        tableView.beginUpdates()
        let indexPath = indexPaths[0]
        indexPaths.removeAtIndex(0)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        if self.shouldLoadMore {
            indexPaths.append(NSIndexPath(forRow: indexPaths.last!.row + 1, inSection: 0))
        }
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        if let delegate = self.delegate {
            delegate.scrollViewDidScrollToTop()
        }
    }
    
    // MARK: InboxCellDelegate
    
    func deletePleek(cell: InboxCell) {

        var indexPath = tableView?.indexPathForCell(cell)
        
        if let indexPath = indexPath {
            let pleek = self.pleeks[indexPath.row]
            PleekAlertView(title: LocalizedString("Confirmation"), message: NSLocalizedString("Are you sure you want to delete this Pleek? There is no way to get back then.", comment : "Are you sure you want to delete this Pleek? There is no way to get back then."), firstButtonTitle: LocalizedString("No"),secondButtonTitle: LocalizedString("Yes"),
            firstAction: { () -> Void in
                self.pleeks.insert(pleek, atIndex: indexPath.row)
                self.tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }, secondAction: { () -> Void in
                pleek.deleteOrHide({ (result, error) -> Void in
                    if let error = error {
                        PleekAlertView(title: LocalizedString("Error"), message: LocalizedString("Problem while deleting this Pleek. Please try again later."), firstButtonTitle: LocalizedString("OK"), secondButtonTitle: nil, firstAction: nil, secondAction: nil)
                        println("Error : \(error.localizedDescription)")
                    }
                })
            })
            
            self.pleeks.removeAtIndex(indexPath.row)
            self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK UISearchBarDelegate

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if count(searchBar.text) == 0 {
            self.searchState = .SearchBeginWithoutText
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let delegate = self.delegate {
            if count(searchText) > 0 {
                self.searchState = .SearchBeginWithText
                delegate.searchBegin(self.tableView)
                if count(searchText) > 2 {
                    delegate.pleekTableViewResultSearchTextChange(self, tableView: self.tableView!, text: searchText, skip: 0)
                }
                
            } else {
                delegate.searchEnd(self.tableView)
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
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}