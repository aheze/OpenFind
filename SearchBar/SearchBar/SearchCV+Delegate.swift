//
//  SearchCV+Delegate.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension SearchViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let origin = searchCollectionViewFlowLayout.layoutAttributes[safe: indexPath.item]?.fullOrigin {
            let targetOrigin = searchCollectionViewFlowLayout.getTargetOffset(for: CGPoint(x: origin, y: 0))
            searchCollectionView.setContentOffset(targetOrigin, animated: true)
        }
    }
    
    //    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    //        print("drag")
    //    }
//    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.isTracking {
//            if let addWordOrigin = searchCollectionViewFlowLayout.layoutAttributes.last?.fullOrigin {
//
//                /// Origin of last word field, relative to the left side of the screen
//                let difference = addWordOrigin - scrollView.contentOffset.x
//                if difference < Constants.addWordFieldSnappingDistance {
//
//                    //                scrollView.scrol
//                    //                    searchCollectionView.
//                    //                    searchCollectionView.setContentOffset(CGPoint(x: addWordOrigin, y: 0), animated: true)
//                    //                    scrollView.contentOffset = scrollView.contentOffset
//                    if !searchCollectionView.showingAddWordField {
//                        print("snap!")
//                        searchCollectionView.showingAddWordField = true
//                        UIView.animate(withDuration: 2) {
//                            self.searchCollectionView.contentOffset = CGPoint(x: addWordOrigin, y: 0)
//                            self.searchCollectionView.layoutIfNeeded()
//                        }
//                    }
//                } else {
//                    searchCollectionView.showingAddWordField = false
//                }
//                print("Diff: \(difference).. scrollView.contentOffset.x: \(scrollView.contentOffset.x)")
//            }
//        }
//        //        print("Sc: \(scrollView.contentOffset), \(scrollView.contentSize), \(searchCollectionViewFlowLayout.layoutAttributes.last?.fullOrigin)")
//        //        if scrollView.contentOffset
//
//    }
}
