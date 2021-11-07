//
//  TabBarVC+Delegate.swift
//  TabBarController
//
//  Created by Zheng on 11/2/21.
//

import UIKit

extension TabBarViewController: UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let middle = contentCollectionView.bounds.width
        let distanceFromMiddle = scrollView.contentOffset.x - middle
        
        if distanceFromMiddle < 0 { /// going to Photos
            let percentage = abs(distanceFromMiddle / middle)
            tabViewModel.tabState = .cameraToPhotos(percentage)
        } else { /// going to Lists
            
            let percentage = abs(distanceFromMiddle / middle)
            tabViewModel.tabState = .cameraToLists(percentage)
        }
        
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        childControllersManager.addChild(at: indexPath.row, to: self, displayIn: cell.contentView)
        print("Will display: \(indexPath)")
        let pageViewController = pages[indexPath.item]
        addChild(pageViewController, in: cell.contentView)
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let pageViewController = pages[indexPath.item]
        removeChild(pageViewController)
//        childControllersManager.remove(at: indexPath.row)
//        childControllersManager.cleanCachedViewControllers(index: indexPath.row)
    }
}
