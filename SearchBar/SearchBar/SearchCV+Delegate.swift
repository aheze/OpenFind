//
//  SearchCV+Delegate.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension SearchViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let origin = searchCollectionViewFlowLayout.cellLayouts[safe: indexPath.item]?.fullOrigin {
            print("Origin: \(origin)---")
            print("Content Size: \(searchCollectionView.contentSize)")
            let targetOrigin = searchCollectionViewFlowLayout.getTargetOffset(for: CGPoint(x: origin, y: 0))
            
//            print("Target: \(targetOrigin)")
//            searchCollectionView.scrollToOffset(targetOrigin.x)
            
//            if targetOrigin.x > CGFloat(1370) {
//                searchCollectionView.setContentOffset(CGPoint(x: 1200, y: 0), animated: true)
//                searchCollectionView.setContentOffset(targetOrigin, animated: true)
//            } else {
            searchCollectionView.setContentOffset(targetOrigin, animated: true)
//            }

        }
    }
}
