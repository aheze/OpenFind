//
//  TabBarVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension TabBarViewController: UICollectionViewDelegate  {
    
    /// called **even** when programmatically set the tab via the icon button...
    /// so, need to use `updateTabBarHeightAfterScrolling` to check whether the user was scrolling or not.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// only update after **the user** scrolled, since `scrollViewDidScroll` is called even when programmatically setting the content offset
        if scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating {
            let middle = contentCollectionView.bounds.width
            let distanceFromMiddle = scrollView.contentOffset.x - middle
            
            let newTab: TabState
            if distanceFromMiddle < 0 { /// going to Photos
                let percentage = abs(distanceFromMiddle / middle)
                if percentage == 0 { /// still completely at camera, no movement
                    newTab = .camera
                    model.updateTabBarHeight?(.camera)
                } else if percentage == 1 { /// finished at photos
                    newTab = .photos
                    model.updateTabBarHeight?(.photos)
                } else { /// use percentage
                    newTab = .cameraToPhotos(percentage)
                    model.updateTabBarHeight?(.camera)
                }
            } else { /// going to Lists
                let percentage = abs(distanceFromMiddle / middle)
                if percentage == 0 {
                    newTab = .camera
                    model.updateTabBarHeight?(.camera)
                } else if percentage == 1 {
                    newTab = .lists
                    model.updateTabBarHeight?(.lists)
                } else {
                    newTab = .cameraToLists(percentage)
                    model.updateTabBarHeight?(.camera)
                }
            }
            
            if let newTab = TabState.notifyBeginChange(current: model.tabState, new: newTab) {
                model.willBeginNavigatingTo?(newTab)
            }
            model.changeTabState(newTab: newTab)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyIfScrolledToStop()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        notifyIfScrolledToStop()
    }
    
    /// stopped scrolling, call delegates
    func notifyIfScrolledToStop() {
        switch model.tabState {
        case .photos, .camera, .lists:
            model.didFinishNavigatingTo?(model.tabState)
        default: break
        }
    }
    
    /// notify delegate and update tab bar height
    func updateTabBarHeightAfterScrolling(_ scrollView: UIScrollView, to tab: TabState) {
        /// only update after **the user** scrolled, since `scrollViewDidScroll` is called even when programmatically setting the content offset
        if scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating {
            model.updateTabBarHeight?(tab)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let pageViewController = pages[indexPath.item]
        addChildViewController(pageViewController, in: cell.contentView)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let pageViewController = pages[indexPath.item]
        removeChildViewController(pageViewController)
    }
}
