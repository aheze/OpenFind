//
//  PhotosSlidesCollectionLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class PhotosSlidesCollectionLayout: UICollectionViewFlowLayout {
    var model: PhotosViewModel
    init(model: PhotosViewModel) {
        self.model = model
        super.init()
    }
    
    var layoutAttributes = [PageLayoutAttributes]()

    /// actual content offset used by `prepare`
    var currentOffset = CGFloat(0)
    
    var contentSize = CGSize.zero /// the scrollable content size of the collection view
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    override func prepare() { /// configure the cells' frames
        super.prepare()
        
        guard
            let collectionView = collectionView,
            let slidesState = model.slidesState
        else { return }
        
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        
        var layoutAttributes = [PageLayoutAttributes]()
        var currentOrigin = CGFloat(0)
        
        for index in slidesState.findPhotos.indices {
            let attributes = PageLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            
            let rect = CGRect(x: currentOrigin, y: 0, width: width, height: height)
            attributes.fullOrigin = currentOrigin
            attributes.frame = rect
            layoutAttributes.append(attributes)
            
            currentOrigin += width
        }

        contentSize = CGSize(width: currentOrigin, height: height)
        self.layoutAttributes = layoutAttributes
        
        currentOffset = collectionView.contentOffset.x
    }
    
    /// boilerplate code
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        let boundsChanged = newBounds.size != collectionView?.bounds.size
        context.invalidateFlowLayoutAttributes = boundsChanged
        context.invalidateFlowLayoutDelegateMetrics = boundsChanged
        return context
    }
    
    /// pass attributes to the collection view flow layout
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[safe: indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        /// edge cells don't shrink, but the animation is perfect
        return layoutAttributes.filter { rect.intersects($0.frame) } /// try deleting this line
    }
    
    /// called upon finger lift
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return getTargetOffset(for: proposedContentOffset, velocity: velocity.x)
    }
    
    /// called after rotation
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if
            let index = model.slidesState?.getCurrentIndex(),
            let attributes = layoutAttributes[safe: index]
        {
            return CGPoint(x: attributes.frame.origin.x, y: 0)
        }
        return CGPoint(x: proposedContentOffset.x, y: 0)
    }
    
    func getTargetOffset(for point: CGPoint, velocity: CGFloat) -> CGPoint {
        let proposedOffset = point.x

        var pickedAttributes = [PageLayoutAttributes?]()
        
        /// prevent scrolling from **photos -> lists** or **lists -> photos**
        let maxDistance = collectionView?.bounds.width ?? 500

        switch velocity {
        case _ where velocity < 0:
            pickedAttributes = layoutAttributes.map { layoutAttribute in
                let isCandidate = layoutAttribute.fullOrigin <= proposedOffset
                return isCandidate ? layoutAttribute : nil
            }
        case _ where velocity > 0:
            pickedAttributes = layoutAttributes.map { layoutAttribute in
                let isCandidate = layoutAttribute.fullOrigin >= proposedOffset
                return isCandidate ? layoutAttribute : nil
            }
        default:
            pickedAttributes = layoutAttributes
        }
        
        /// find closest origin
        var (closestAttribute, closestAttributeIndex, closestDistance): (PageLayoutAttributes?, Int, CGFloat) = (nil, 0, CGFloat.infinity)
        for (index, attribute) in pickedAttributes.enumerated() {
            if let layoutAttribute = attribute {
                let distance = abs(layoutAttribute.fullOrigin - proposedOffset)
                if distance < closestDistance {
                    closestAttributeIndex = index
                    closestAttribute = layoutAttribute
                    closestDistance = distance /// for keeping track later
                }
            }
        }
        
        /// check if it's within bounds
        if let closestAttributeUnwrapped = closestAttribute, velocity != 0 {
            let distance = abs(closestAttributeUnwrapped.fullOrigin - currentOffset)
            if distance > maxDistance {
                if let currentIndex = model.slidesState?.getCurrentIndex() {
                    let nextIndex = currentIndex + 1
                    let previousIndex = currentIndex - 1
                    if velocity >= 0, layoutAttributes.indices.contains(nextIndex) {
                        closestAttributeIndex = nextIndex
                    } else if velocity < 0, layoutAttributes.indices.contains(previousIndex) {
                        closestAttributeIndex = previousIndex
                    } else {
                        closestAttributeIndex = currentIndex
                    }
                    closestAttribute = layoutAttributes[closestAttributeIndex]
                }
            }
        }
        
        if let findPhoto = model.slidesState?.findPhotos[safe: closestAttributeIndex] {
            model.slidesState?.currentPhoto = findPhoto.photo
        }
        return CGPoint(x: closestAttribute?.frame.origin.x ?? point.x, y: 0)
    }
}
