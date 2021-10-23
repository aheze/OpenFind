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
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking {
            if let addWordOrigin = searchCollectionViewFlowLayout.layoutAttributes.last?.fullOrigin {

                /// Origin of last word field, relative to the left side of the screen
                let difference = addWordOrigin - scrollView.contentOffset.x
                if difference < Constants.addWordFieldSnappingDistance {
                    if !searchCollectionView.showingAddWordField {
                        searchCollectionView.isScrollEnabled = false
                        searchCollectionView.showingAddWordField = true
                        
                        let beginningOffset = searchCollectionViewFlowLayout.currentOffset
                        let adjustedTargetOrigin = searchCollectionViewFlowLayout.getTargetOffset(for: CGPoint(x: addWordOrigin, y: 0)).x
                        let targetOffsetDelta = adjustedTargetOrigin - searchCollectionViewFlowLayout.currentOffset
                        
                        searchCollectionView.setContentOffset(CGPoint(x: beginningOffset, y: 0), animated: false)
                        
                        let displayLink = CADisplayLink(target: self, selector: #selector(self.displayLinkDidFire))
                        searchScrollTimer = ScrollTimer(
                            displayLink: displayLink,
                            startTime:  CACurrentMediaTime(),
                            animationLength: 2,
                            beginningOffset: beginningOffset,
                            targetOffsetDelta: targetOffsetDelta
                        )
                        displayLink.add(to: .main, forMode: .common)
                        
                    }
                } else {
                    searchCollectionView.showingAddWordField = false
                }
            }
        }

    }
    
    @objc func displayLinkDidFire(_ displayLink: CADisplayLink) {
        
        if let timer = searchScrollTimer {
            var elapsedTime = CACurrentMediaTime() - timer.startTime
            
            if elapsedTime > timer.animationLength {
                stopDisplayLink()
                elapsedTime = timer.animationLength /// clamp the elapsed time to the animation length
                searchCollectionView.isScrollEnabled = true
            }
            
            let progress = elapsedTime / timer.animationLength
            let offset = timer.beginningOffset + (timer.targetOffsetDelta * progress)
            searchCollectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        }
        
        /// do your animation logic here
    }
    
    /// invalidate display link if it's non-nil, then set to nil
    func stopDisplayLink() {
        searchScrollTimer?.displayLink.invalidate()
        searchScrollTimer = nil
    }
}
