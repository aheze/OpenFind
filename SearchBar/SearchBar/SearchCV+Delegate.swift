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
                        
                        beginningOffset = searchCollectionViewFlowLayout.currentOffset
                        
                        let adjustedTargetOrigin = searchCollectionViewFlowLayout.getTargetOffset(for: CGPoint(x: addWordOrigin, y: 0)).x
                        targetOffsetDelta = adjustedTargetOrigin - searchCollectionViewFlowLayout.currentOffset
                        
                        print("---")
                        searchCollectionView.setContentOffset(CGPoint(x: beginningOffset!, y: 0), animated: false)
                        
                        
                            self.stopDisplayLink() /// make sure to stop a previous running display link
                            self.startTime = CACurrentMediaTime() // reset start time
                            
                            /// create displayLink and add it to the run-loop
                            let displayLink = CADisplayLink(target: self, selector: #selector(self.displayLinkDidFire))
                            displayLink.add(to: .main, forMode: .common)
                            self.displayLink = displayLink
                        
                        
                        
                    }
                } else {
                    searchCollectionView.showingAddWordField = false
                }
//                print("Diff: \(difference).. scrollView.contentOffset.x: \(scrollView.contentOffset.x)")
            }
        }
        //        print("Sc: \(scrollView.contentOffset), \(scrollView.contentSize), \(searchCollectionViewFlowLayout.layoutAttributes.last?.fullOrigin)")
        //        if scrollView.contentOffset

    }
    
    @objc func displayLinkDidFire(_ displayLink: CADisplayLink) {
        
        var elapsedTime = CACurrentMediaTime() - startTime
        
        if elapsedTime > animationLength {
            stopDisplayLink()
            elapsedTime = animationLength /// clamp the elapsed time to the animation length
            searchCollectionView.isScrollEnabled = true
        }
        
        let progress = elapsedTime / animationLength
//        print("Progress: \(progress)")
//        print("B: \(beginningOffset)")
//        print("T: \(targetOffsetDelta)")
        let offset = (beginningOffset ?? 0) + ((targetOffsetDelta ?? 0) * progress)
//        print("O: \(offset)")
        searchCollectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        
        /// do your animation logic here
    }
    
    /// invalidate display link if it's non-nil, then set to nil
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
}
