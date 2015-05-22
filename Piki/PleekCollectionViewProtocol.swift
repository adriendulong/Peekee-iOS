//
//  PleekCollectionViewDataSource.swift
//  Peekee
//
//  Created by Kevin CATHALY on 19/05/2015.
//  Copyright (c) 2015 PikiChat. All rights reserved.
//

import UIKit

protocol PleekCollectionViewDelegate: class {
    func pleekCollectionView(collectionView: UICollectionView?, didSelectPleek pleek:Pleek, atIndexPath indexPath: NSIndexPath?)
    func pleekCollectionViewLoadMore(pleekProtocol: PleekCollectionViewProtocol, collectionView: UICollectionView, toSkip: Int)
    func scrollViewDidScrollToTop()
}

class PleekCollectionViewProtocol: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    weak var delegate: PleekCollectionViewDelegate? = nil
    var shouldLoadMore: Bool = true
    var isLoadingMore: Bool = false
    var pleeks: [Pleek] = []
    weak var collectionView: UICollectionView?
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.shouldLoadMore {
            return count(self.pleeks) + 1
        }
        
        return count(self.pleeks)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
            if let delegate = self.delegate {
                weak var weakSelf = self
                self.isLoadingMore = true
                delegate.pleekCollectionViewLoadMore(weakSelf!, collectionView: collectionView, toSkip: count(self.pleeks))
            }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let delegate = self.delegate {
            delegate.pleekCollectionView(collectionView, didSelectPleek: self.pleeks[indexPath.row], atIndexPath: indexPath)
        }
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
    
    func updateCollectionView(collectionView: UICollectionView,  pleeks: [Pleek]) {
        var indexPaths = self.updateList(pleeks)
        collectionView.performBatchUpdates({ () -> Void in
            let indexPath = indexPaths[0]
            indexPaths.removeAtIndex(0)
            collectionView.reloadItemsAtIndexPaths([indexPath])
            if self.shouldLoadMore {
                indexPaths.append(NSIndexPath(forRow: indexPaths.last!.item + 1, inSection: 0))
            }
            collectionView.insertItemsAtIndexPaths(indexPaths)

        }, completion: nil)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        if let delegate = self.delegate {
            delegate.scrollViewDidScrollToTop()
        }
    }

    
}