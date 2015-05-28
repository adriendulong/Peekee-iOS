//
//  PleekCollectionViewDataSource.swift
//  Peekee
//
//  Created by Kevin CATHALY on 19/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import UIKit

protocol PleekCollectionViewControllerDelegate: class {
    func scrollViewDidScrollToTop()
    func shouldRefresh()
    func newContent(controller: UIViewController)
}

class PleekCollectionViewController: UICollectionViewController {

    var key: String = ""
    private var mostRecentDate: NSDate {
        let userDefault = NSUserDefaults.standardUserDefaults()
        
        if let date = userDefault.objectForKey(self.key) as? NSDate {
            return date
        }
        
        return NSDate(timeIntervalSince1970: 0)
    }
    
    weak var delegate: PleekCollectionViewControllerDelegate? = nil
    var dataSource: ((withCache: Bool, skip: Int, completed: PleekCompletionHandler) -> ())? {
        didSet {
            self.getBestPleek(true)
        }
    }
    
    private var shouldLoadMore: Bool = true
    private var isLoadingMore: Bool = false
    private var pleeks: [Pleek] = []
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshPleek"), forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    } ()
    
    // MARK: Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor(red: 227.0/255.0, green: 234.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        self.collectionView?.addSubview(self.refreshControl)
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView?.scrollsToTop = false
        
        self.collectionView?.registerClass(BestCell.self, forCellWithReuseIdentifier: "BestCollectionViewCell")
        self.collectionView?.registerClass(LoadMoreCollectionViewCell.self, forCellWithReuseIdentifier: "LoadMoreCollectionViewCellIdentifier")
        
        let refreshControl = self.refreshControl
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.shouldLoadMore {
            return count(self.pleeks) + 1
        }
        
        return count(self.pleeks)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == count(self.pleeks) && self.shouldLoadMore {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LoadMoreCollectionViewCellIdentifier", forIndexPath: indexPath) as! LoadMoreCollectionViewCell
            cell.spinner.startAnimating()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BestCollectionViewCell", forIndexPath: indexPath) as! BestCell
        let pleek = self.pleeks[indexPath.row]
        cell.configureFor(pleek)
        
        //Load more
        if indexPath.row == count(self.pleeks) - 5 && count(self.pleeks) > 0 && !self.isLoadingMore && self.shouldLoadMore {
            weak var weakSelf = self
            self.isLoadingMore = true
            self.loadMore()
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let pleek = self.pleeks[indexPath.row]
        self.showPleek(pleek)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if indexPath.row == count(self.pleeks) && self.shouldLoadMore {
            return CGSizeMake(CGRectGetWidth(collectionView.frame), 90.0)
        }
        
        let width = (CGRectGetWidth(collectionView.frame) - 26.0) / 2.0
        let height = (width / 3.0 * 4.0) + 1
        
        return CGSizeMake(width, height)
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        if let delegate = self.delegate {
            delegate.scrollViewDidScrollToTop()
        }
    }

    // MARK: Action
    
    func showPleek(pleek: Pleek) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let pleekVC = storyboard.instantiateViewControllerWithIdentifier("PleekViewController") as? PleekViewController {
            pleekVC.from = "Best"
            pleekVC.mainPiki = pleek
            self.navigationController?.pushViewController(pleekVC, animated: true)
        }
    }
    
    // MARK: Data
    
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
    
    func updateCollectionView(pleeks: [Pleek]) {
        var indexPaths = self.updateList(pleeks)
        self.collectionView?.performBatchUpdates({ () -> Void in
            let indexPath = indexPaths[0]
            indexPaths.removeAtIndex(0)
            self.collectionView?.reloadItemsAtIndexPaths([indexPath])
            if self.shouldLoadMore {
                indexPaths.append(NSIndexPath(forRow: indexPaths.last!.item + 1, inSection: 0))
            }
            self.collectionView?.insertItemsAtIndexPaths(indexPaths)
            }, completion: nil)
    }
    
    func refreshPleek() {
        self.getBestPleek(false)
    }
    
    func refresh() {
        if let delegate = self.delegate {
            delegate.shouldRefresh()
        }
    }
    
    func getBestPleek(withCache: Bool) {
        if let dataSource = self.dataSource {
            weak var weakSelf = self
            dataSource(withCache: withCache, skip: 0, completed: { (pleeks, error) -> () in
                if error != nil {
                    println("Error : \(error!.localizedDescription)")
                } else {
                    
                    if pleeks!.count > 0 {
                        if pleeks![0].lastUpdateDate.isGreaterThanDate(self.mostRecentDate) {
                            self.setMostRecent(pleeks![0].lastUpdateDate)
                            if let delegate = self.delegate {
                                delegate.newContent(self)
                            }
                        }
                    }
                    
                    if count(pleeks!) < Constants.LoadPleekLimit {
                        weakSelf?.shouldLoadMore = false
                    } else {
                        weakSelf?.shouldLoadMore = true
                    }
                    weakSelf?.pleeks = pleeks!

                    
                    weakSelf?.refreshControl.endRefreshing()
                    weakSelf?.collectionView?.reloadData()
                }
            })
        }
    }
    
    func setMostRecent(date: NSDate) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(date, forKey: self.key)
        userDefault.synchronize()
    }
    
    func loadMore() {
        if let dataSource = self.dataSource {
            weak var weakSelf = self
            dataSource(withCache: true, skip: count(self.pleeks), completed: { (pleeks, error) -> Void in
                weakSelf?.loadMoreResult(pleeks, error: error)
            })
        }
    }
    
    func loadMoreResult(pleeks: [Pleek]?, error: NSError?) {
        if let error = error {
            println("Error : \(error.localizedDescription)")
        } else if let pleeks = pleeks {
            self.updateCollectionView(pleeks)
        }
        self.isLoadingMore = false
    }
    
}