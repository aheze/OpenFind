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
}
