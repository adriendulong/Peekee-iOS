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
    func scrollViewDidScrollToTop()
}

import UIKit

class PleekTableViewProtocol: NSObject, UITableViewDataSource, UITableViewDelegate, InboxCellDelegate, UISearchBarDelegate {
    
    let isSearchable: Bool
    var pleeks: [Pleek] = [] {
        didSet {
            if count(self.pleeks) > 0 && self.isSearchable {
                self.tableView?.tableHeaderView = self.searchBar
            } else {
                self.tableView?.tableHeaderView = nil
            }
        }
    }
    
    weak var tableView: UITableView?
    
    weak var delegate: PleekTableViewDelegate? = nil
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView!.frame), 50)
        searchBar.barTintColor = UIColor(red: 57.0/255.0, green: 73.0/255.0, blue: 171.0/255.0, alpha: 1.0)
        return searchBar
    } ()
    
    var isLoadingMore: Bool = false
    var shouldLoadMore: Bool = true

    
    init(searchable: Bool) {
        self.isSearchable = searchable
        super.init()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.shouldLoadMore {
            return count(self.pleeks) + 1
        }
        
        return count(self.pleeks)
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
        if pleek.nbReaction > 0 {
            return CGRectGetWidth(screenRect) / 3.0 * 2.0 + 60.0
        }
        return CGRectGetWidth(screenRect) + 60
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == count(self.pleeks) && self.shouldLoadMore {
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
}